//
//  PacketsViewController.swift
//  Bagel
//
//  Created by Yagiz Gurgul on 30/08/2018.
//  Copyright © 2018 Yagiz Lab. All rights reserved.
//

import Cocoa

class PacketsViewController: BaseViewController, NSTableViewDelegate, NSTableViewDataSource {

    var viewModel: PacketsViewModel?
    var onPacketSelect : ((BagelPacket) -> ())?
    
    @IBOutlet weak var tableView: BaseTableView!
    
    override func setup() {
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.viewModel?.onChange = { [weak self] in
            
            self?.refresh()
        }
        
        self.setupTableViewHeaders()
    }
    
    
    func refresh() {
        
        self.tableView.reloadData()
        
        if let selectedItemIndex = self.viewModel?.selectedItemIndex {
            
            self.tableView.selectRowIndexes(IndexSet(integer: selectedItemIndex), byExtendingSelection: false)
        }
    }
    
    
    func setupTableViewHeaders() {
        
        for tableColumn in self.tableView.tableColumns {
            
            if tableColumn.identifier.rawValue == "statusCode" {
                
                tableColumn.headerCell = FlatTableHeaderCell(textCell: "Status")
                tableColumn.width = 40
                
            }else if tableColumn.identifier.rawValue == "url" {
                
                tableColumn.headerCell = FlatTableHeaderCell(textCell: "URL")
                tableColumn.width = self.view.frame.size.width - 40
            }
        }
    }
    
}

extension PacketsViewController
{
    func numberOfRows(in tableView: NSTableView) -> Int {
        
        return self.viewModel?.itemCount() ?? 0
    }
    
    
//    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
//        
//        return FlatTableRowView()
//    }
    
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        if (tableColumn?.identifier)!.rawValue == "statusCode" {
            
            let cell: StatusPacketTableCellView = self.tableView.makeView(withOwner: nil)!
            cell.packet = self.viewModel?.item(at: row)
            cell.backgroundStyle = .normal
            return cell
            
        }else if (tableColumn?.identifier)!.rawValue == "url" {
            
            let cell: URLPacketTableCellView = self.tableView.makeView(withOwner: nil)!
            cell.packet = self.viewModel?.item(at: row)
            cell.backgroundStyle = .normal
            return cell
        }
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        
        let selectedRow = self.tableView.selectedRow
        
        if selectedRow >= 0 , let item = self.viewModel?.item(at: selectedRow) {
            
            if item !== self.viewModel?.selectedItem {
                
                self.onPacketSelect?(item)
            }
        }
    }
    
}
