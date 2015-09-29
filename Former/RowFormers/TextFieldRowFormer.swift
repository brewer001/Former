//
//  TextFieldRowFormer.swift
//  Former-Demo
//
//  Created by Ryo Aoyama on 7/25/15.
//  Copyright © 2015 Ryo Aoyama. All rights reserved.
//

import UIKit

public protocol TextFieldFormableRow: FormableRow {
    
    var observer: FormerObserver { get }
    
    func formerTextField() -> UITextField
    func formerTitleLabel() -> UILabel?
}

public class TextFieldRowFormer: RowFormer, FormerValidatable {
    
    override public var canBecomeEditing: Bool {
        return enabled
    }
    
    public var onValidate: (String? -> Bool)?
    
    public var onTextChanged: (String -> Void)?
    public var text: String?
    public var placeholder: String?
    public var textDisabledColor: UIColor? = .lightGrayColor()
    public var titleDisabledColor: UIColor? = .lightGrayColor()
    public var titleEditingColor: UIColor?
    public var returnToNextRow = true
    
    private var textColor: UIColor?
    private var titleColor: UIColor?
    
    public init<T: UITableViewCell where T: TextFieldFormableRow>(
        cellType: T.Type,
        instantiateType: Former.InstantiateType,
        onTextChanged: (String -> Void)? = nil,
        cellSetup: (T -> Void)? = nil) {
            super.init(cellType: cellType, instantiateType: instantiateType, cellSetup: cellSetup)
            self.onTextChanged = onTextChanged
    }
    
    deinit {
        if let row = cell as? TextFieldFormableRow {
            let textField = row.formerTextField()
            textField.delegate = nil
        }
    }
    
    public override func update() {
        super.update()
        
        cell?.selectionStyle = .None
        if let row = cell as? TextFieldFormableRow {
            let titleLabel = row.formerTitleLabel()
            let textField = row.formerTextField()
            textField.text = text
            textField.placeholder =? placeholder
            textField.userInteractionEnabled = false
            textField.delegate = self
            
            if enabled {
                if isEditing {
                    titleColor ?= titleLabel?.textColor
                    titleLabel?.textColor =? titleEditingColor
                } else {
                    titleLabel?.textColor =? titleColor
                    titleColor = nil
                }
                textField.textColor =? textColor
                textColor = nil
            } else {
                titleColor ?= titleLabel?.textColor
                textColor ?= textField.textColor
                titleLabel?.textColor = titleDisabledColor
                textField.textColor = textDisabledColor
            }
            
            row.observer.setTargetRowFormer(self,
                control: textField,
                actionEvents: [
                    ("textChanged:", .EditingChanged),
                    ("editingDidBegin:", .EditingDidBegin),
                    ("editingDidEnd:", .EditingDidEnd)
                ]
            )
        }
    }
    
    public override func cellSelected(indexPath: NSIndexPath) {
        super.cellSelected(indexPath)
        
        if let row = cell as? TextFieldFormableRow where enabled {
            let textField = row.formerTextField()
            if !textField.editing {
                textField.userInteractionEnabled = true
                textField.becomeFirstResponder()
            }
        }
    }
    
    public func validate() -> Bool {
        return onValidate?(text) ?? true
    }
    
    public func textChanged(textField: UITextField) {
        if enabled {
            let text = textField.text ?? ""
            self.text = text
            onTextChanged?(text)
        }
    }
    
    public func editingDidBegin(textField: UITextField) {
        if let row = cell as? TextFieldFormableRow where enabled {
            let titleLabel = row.formerTitleLabel()
            titleColor ?= titleLabel?.textColor
            titleLabel?.textColor =? titleEditingColor
        }
    }
    
    public func editingDidEnd(textField: UITextField) {
        if let row = cell as? TextFieldFormableRow {
            let titleLabel = row.formerTitleLabel()
            if enabled {
                titleLabel?.textColor =? titleColor
                titleColor = nil
            } else {
                titleColor ?= titleLabel?.textColor
                titleLabel?.textColor =? titleEditingColor
            }
            row.formerTextField().userInteractionEnabled = false
        }
    }
}

extension TextFieldRowFormer: UITextFieldDelegate {
    
    public func textFieldShouldReturn(textField: UITextField) -> Bool {
        if returnToNextRow {
            let returnToNextRow = (former?.canBecomeEditingNext() ?? false) ?
                former?.becomeEditingNext :
                former?.endEditing
            returnToNextRow?()
        }
        return !returnToNextRow
    }
}