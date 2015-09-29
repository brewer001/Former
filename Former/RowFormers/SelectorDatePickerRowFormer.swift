//
//  SelectorDatePickerRowFormer.swift
//  Former-Demo
//
//  Created by Ryo Aoyama on 8/24/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//

import UIKit

public protocol SelectorDatePickerFormableRow: FormableRow {
    
    var selectorDatePicker: UIDatePicker? { get set } // Not need to set UIDatePicker instance.
    var selectorAccessoryView: UIView? { get set } // Not need to set UIView instance.
    
    func formerTitleLabel() -> UILabel?
    func formerDisplayLabel() -> UILabel?
}

public class SelectorDatePickerRowFormer: RowFormer, FormerValidatable {
    
    override public var canBecomeEditing: Bool {
        return self.enabled
    }
    
    public var onValidate: (NSDate -> Bool)?
    
    public var onDateChanged: (NSDate -> Void)?
    public var inputViewUpdate: (UIDatePicker -> Void)?
    public var displayTextFromDate: (NSDate -> String)?
    public var date: NSDate = NSDate()
    public var inputAccessoryView: UIView?
    public var titleDisabledColor: UIColor? = .lightGrayColor()
    public var displayDisabledColor: UIColor? = .lightGrayColor()
    
    private var titleColor: UIColor?
    private var displayTextColor: UIColor?
    
    private lazy var inputView: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.addTarget(self, action: "dateChanged:", forControlEvents: .ValueChanged)
        return datePicker
        }()
    
    public init<T: UITableViewCell where T: SelectorDatePickerFormableRow>(
        cellType: T.Type,
        instantiateType: Former.InstantiateType,
        onDateChanged: (NSDate -> Void)? = nil,
        cellSetup: (T -> Void)? = nil) {
            super.init(cellType: cellType, instantiateType: instantiateType, cellSetup: cellSetup)
            self.onDateChanged = onDateChanged
    }
    
    public override func update() {
        super.update()
        
        inputViewUpdate?(inputView)
        if let row = cell as? SelectorDatePickerFormableRow {
            row.selectorDatePicker = inputView
            row.selectorAccessoryView = inputAccessoryView
            
            let titleLabel = row.formerTitleLabel()
            let displayLabel = row.formerDisplayLabel()
            displayLabel?.text = displayTextFromDate?(date) ?? "\(date)"
            if self.enabled {
                titleLabel?.textColor =? titleColor
                displayLabel?.textColor =? displayTextColor
                titleColor = nil
                displayTextColor = nil
            } else {
                titleColor ?= titleLabel?.textColor
                displayTextColor ?= displayLabel?.textColor
                titleLabel?.textColor = titleDisabledColor
                displayLabel?.textColor = displayDisabledColor
            }
        }
    }
    
    public override func cellSelected(indexPath: NSIndexPath) {
        super.cellSelected(indexPath)
        former?.deselect(true)
        if enabled {
            cell?.becomeFirstResponder()
        }
    }
    
    public func validate() -> Bool {
        return onValidate?(date) ?? true
    }
    
    public dynamic func dateChanged(datePicker: UIDatePicker) {
        if let row = cell as? SelectorDatePickerFormableRow where enabled {
            let date = datePicker.date
            self.date = date
            row.formerDisplayLabel()?.text = displayTextFromDate?(date) ?? "\(date)"
            onDateChanged?(date)
        }
    }
}