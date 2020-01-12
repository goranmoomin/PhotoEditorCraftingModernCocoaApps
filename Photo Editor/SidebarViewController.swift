/*
 Copyright (C) 2016 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The SidebarViewController controls the sidebar. The user can use the plus button to select a directory to show the sidebar contents. This user chosen directory is then saved as a bookmark for proper operation with Sandboxing when re-opening the window.
*/

import Cocoa

class SidebarViewController: NSViewController, PhotoControllerConsumer {

    @IBOutlet weak var sidebarTableView: NSTableView!
    @IBOutlet weak var visualEffectView: NSVisualEffectView!
    @IBOutlet weak var sidebarScrollView: NSScrollView!

    // An array of titles to show and icons (images)
    var tableContents: [ImageItem] = [ImageItem]()
    var filteredTableContents: [ImageItem] = [ImageItem]()
    var bookmarkData: Data?
    var searchContainerViewHeight: CGFloat = 0.0
    weak var observingLayoutRectInWindow: NSWindow?

    var searchString = ""
    
    // PhotoControllerConsumer protocol implementation
    var photoController: PhotoController?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load the search view controller; this uses hard casts, because we need to know if it fails or some reason (it is a programmer error if it does fail)
        let searchViewController = storyboard!.instantiateController(withIdentifier: "SearchViewController") as! NSViewController
        addChild(searchViewController)
        
        // Directly add the view to the clip view
        let searchContainerView = searchViewController.view
        
        let clipView = sidebarScrollView.contentView as! SidebarClipView
        clipView.addSubview(searchContainerView)
        searchContainerViewHeight = searchContainerView.frame.size.height
        clipView.accessoryView = searchContainerView
        
        // Drop the autoresizing constraints that would be implicitly created for us
        searchContainerView.translatesAutoresizingMaskIntoConstraints = false
        
        // Create some constraints to pin it to the top; in particular, pin the bottom of the search container to the top of the scrollview (it's 0 position)
        NSLayoutConstraint.activate([
            clipView.topAnchor.constraint(equalTo: searchContainerView.bottomAnchor),
            clipView.leadingAnchor.constraint(equalTo: searchContainerView.leadingAnchor),
            clipView.trailingAnchor.constraint(equalTo: searchContainerView.trailingAnchor),
            ])
        
        sidebarScrollView.automaticallyAdjustsContentInsets = false // We manually do it
    }
    
    // MARK: - State Restoration
    
    override func encodeRestorableState(with coder: NSCoder) {
        super.encodeRestorableState(with: coder)
        
        if let bookmarkData = self.bookmarkData {
            coder.encode(bookmarkData, forKey: "BookmarkData")
        }
    }
    
    override func restoreState(with coder: NSCoder) {
        super.restoreState(with: coder)
        
        bookmarkData = coder.decodeObject(forKey: "BookmarkData") as? Data
        if let bookmarkData = self.bookmarkData {
            // If we have data, open it up!
            do {
                var stale = false
                let directoryURL = try URL(resolvingBookmarkData: bookmarkData, bookmarkDataIsStale: &stale)
                loadTableContentsFromURL(baseDirectoryURL: directoryURL)
            } catch let error as NSError  {
                presentError(error)
            }
        }
    }
    
    // MARK: - Scroll Inset Management
    
    private func updateScrollViewContentInsets() {
        let window = view.window!
        let contentLayoutRect = window.contentLayoutRect
        let topInset = (window.contentView!.frame.size.height - contentLayoutRect.height) + searchContainerViewHeight
        
        sidebarScrollView.contentInsets = NSEdgeInsets(top: topInset, left: 0, bottom: 0, right: 0)
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()

        if view.window != observingLayoutRectInWindow {
            // Un-register previous observation, if there was one
            if let observingWindow = observingLayoutRectInWindow {
                observingWindow.removeObserver(self, forKeyPath: "contentLayoutRect")
            }
            
            // Should always be true in viewWillAppear
            if let window = view.window {
                // Keep an eye on the contentLayoutRect via KVO
                window.addObserver(self, forKeyPath: "contentLayoutRect", options: [], context: nil);
            }
            
            observingLayoutRectInWindow = view.window
        }
        
        updateScrollViewContentInsets()
    }
    
    
    override func viewWillDisappear() {
        if let observingWindow = observingLayoutRectInWindow {
            observingWindow.removeObserver(self, forKeyPath: "contentLayoutRect")
            observingLayoutRectInWindow = nil
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        precondition(keyPath! == "contentLayoutRect", "We are only observing the contentLayoutRect")
        updateScrollViewContentInsets()
    }
    
    private func presentError(error: NSError) {
        if let window = view.window {
            window.presentError(error)
        } else {
            NSApp.presentError(error)
        }
    }
    
    // MARK: - Data Shuffling
    
    // saving the data as a URL allows us to do state restoration
    // In order for this to work, com.apple.security.files.bookmarks.app-scope was added to the entitlements plist file
    private func saveURLAsBookmarkData(_ url: URL) {
        do {
            bookmarkData = try url.bookmarkData(options: [.withSecurityScope], includingResourceValuesForKeys: nil, relativeTo: nil)
            invalidateRestorableState()
        } catch let error as NSError  {
            presentError(error)
        }
    }
    
    private func loadTableContentsFromURL(baseDirectoryURL: URL) {
        do {
            let filesURLs = try FileManager.default.contentsOfDirectory(at: baseDirectoryURL, includingPropertiesForKeys: [URLResourceKey.localizedNameKey], options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            let imageUTIs = NSImage.imageTypes
            
            for fileURL: URL in filesURLs {
                let resourceValues = try fileURL.resourceValues(forKeys: [.typeIdentifierKey])
                if let typeIdentifier = resourceValues.typeIdentifier {
                    if (imageUTIs.contains(typeIdentifier)) {
                        tableContents.append(ImageItem(url: fileURL))
                    }
                }
            }
            filteredTableContents = tableContents
            sidebarTableView.reloadData()
            saveURLAsBookmarkData(baseDirectoryURL)
            
        } catch let error as NSError  {
            presentError(error)
        }
    }
    
    private func filterTable(with string: String) {
        if searchString != string {
            searchString = string;
            if searchString == "" {
                filteredTableContents = tableContents
            } else {
                filteredTableContents = []
                for item in tableContents {
                    if item.title.localizedCaseInsensitiveContains(string) {
                        filteredTableContents.append(item)
                    }
                }
            }
            sidebarTableView.reloadData()
        }
    }
    
    
    @IBAction func btnOpenClicked(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        openPanel.beginSheetModal(for: view.window!) { result in
            if (result == NSApplication.ModalResponse.OK) {
                if let directoryURL = openPanel.url {
                    self.loadTableContentsFromURL(baseDirectoryURL: directoryURL)
                }
            }
        }
    }
    
    @IBAction func searchFieldChanged(_ sender: NSSearchField) {
        filterTable(with: sender.stringValue)
    }
    
}

// Extensions allow a clean and isolated implementation of delegate/datasource methods
extension SidebarViewController: NSTableViewDelegate, NSTableViewDataSource {
    
    private func loadImage(for imageItem: ImageItem, preferredSize: NSSize, row: NSInteger) {
        // If we aren't loading it, start now
        guard !imageItem.loadingImage else { return }
        
        imageItem.loadingImage = true
        
        let queue = DispatchQueue.global(qos: .userInteractive)
        queue.async {
            let destRect = NSMakeRect(0, 0, preferredSize.width, preferredSize.height)
            // Load the image
            let image = NSImage(contentsOf: imageItem.url)!
            // resize the image; we don't want to do this on the foreground thread, so we create a specific thumbnail to use
            let thumbnailImage = NSImage(size: preferredSize)
            thumbnailImage.lockFocus()
            
            image.draw(in: destRect)

            thumbnailImage.unlockFocus()
            
            // Kick back the actual work to the main thread (that is the only location where we access the imageItem for threadsafety)
            DispatchQueue.main.async {
                // Save it for later
                imageItem.image = thumbnailImage;
                imageItem.loadingImage = false
                // Ping this row to reload; the image view may be different at this time, so we get the current cell view (if available) and assign to it
                if let cellView = self.sidebarTableView.view(atColumn: 0, row: row, makeIfNecessary: false) as? NSTableCellView {
                    cellView.imageView?.image = thumbnailImage
                }
            }
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return filteredTableContents.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let imageItem = filteredTableContents[row]
        // We want this to fail if any conditions aren't met; if it fails, something isn't setup right and should be resolved
        let cellView = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as! NSTableCellView
        
        // Display image title/name
        if let label = cellView.textField {
            label.stringValue = imageItem.title
        }
        
        let imageView = cellView.imageView!
        // Do we have an image? If not, start loading it now...
        if imageItem.image == nil {
            loadImage(for: imageItem, preferredSize: imageView.frame.size, row: row)
        } else {
            imageView.image = imageItem.image
        }
        
        return cellView
    }
    
    // Demonstrate how to do "swipe to delete"
    func tableView(_ tableView: NSTableView, rowActionsForRow row: Int, edge: NSTableView.RowActionEdge) -> [NSTableViewRowAction] {
        switch edge {
            case .trailing:
                let result = NSTableViewRowAction(style: .destructive, title: "Remove", handler: { action, row in
                    let item: ImageItem = self.filteredTableContents[row]
                    
                    // remove from the filtered and unfiltered item
                    self.filteredTableContents.remove(at: row)
                    if let i = self.tableContents.firstIndex(of: item) {
                        self.tableContents.remove(at: i)
                    }
                    
                    self.sidebarTableView.removeRows(at: IndexSet(integer: row), withAnimation: [.slideUp])
                })
                
                return [result]
            
            default:
                return []
        }
    }

    // Demonstrate drag flocking in a table
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {
        let imageItem = filteredTableContents[row]
        return imageItem.url as NSPasteboardWriting
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        // Change the image; this is synchronous.
        let selectedRow = sidebarTableView.selectedRow
        if selectedRow != -1 {
            if let image = NSImage(contentsOf: filteredTableContents[selectedRow].url) {
                photoController?.setPhotoImage(image)
            }
        }
    }
}


/// A basic encapsulation of a sidebar item: an image, title, URL and state as to whether or not we have loaded the image (meaning, a thumbnail was created).
class ImageItem: Equatable {
    var image: NSImage? // Used as a thumbnail image in the SidebarViewController
    var title: String
    var url: URL
    var loadingImage = false
    
    init(url: URL) {
        self.url = url
        self.title = url.lastPathComponent
    }
}

func == (lhs: ImageItem, rhs: ImageItem) -> Bool {
    // same URL means we are the same
    return lhs.url == rhs.url
}
