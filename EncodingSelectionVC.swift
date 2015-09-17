//
//  EncodingSelectionViewController.swift
//  Binarify
//
//  Created by Nick Podratz on 09.09.15.
//  Copyright (c) 2015 Nick Podratz. All rights reserved.
//

import UIKit

protocol EncodingSelectorDelegate {
    func didSelectEncoding(newEncoding: Encoding)
}

class EncodingSelectionController: UITableViewController {

    var delegate: EncodingSelectorDelegate?
    var selectedEncoding: Encoding! {
        didSet{
            if isViewLoaded() && selectedEncoding != nil {
                setCheckmark(forCellWithTag: selectedEncoding.rawValue)
            }
        }
    }
    
    
    // MARK: Life Cycle
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        setCheckmark(forCellWithTag: selectedEncoding.rawValue)
    }
    
    
    // MARK: - Private Function
    
    private func setCheckmark(forCellWithTag row: Int) {
        for cell in tableView.visibleCells {
            cell.accessoryType = (cell.tag == row) ? .Checkmark : .None
        }
    }

    
    // MARK: - Table View Delegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedEncoding = Encoding(rawValue: indexPath.row)!
        delegate?.didSelectEncoding(selectedEncoding)
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
}
