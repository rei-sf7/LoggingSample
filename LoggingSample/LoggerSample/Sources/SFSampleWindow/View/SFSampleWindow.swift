import UIKit

final class SFSampleWindow: UIViewController {
    
    var textField: UITextField? = nil
    var button: UIButton? = nil
    
    private var viewModel: SFSampleWindowViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = SFSampleWindowViewModel()
        self.view.backgroundColor = self.viewModel.backgroundColor
        
        // テキスト入力欄
        let textW: CGFloat = self.view.frame.maxX * 0.8
        let textH: CGFloat = 80
        let textXPos: CGFloat = (self.view.frame.maxX / 2) - (textW / 2)
        let textYPos: CGFloat = self.view.frame.maxY * 0.2
        let frame = CGRect(x: textXPos, y: textYPos, width: textW, height: textH)
        let textField = UITextField(frame: frame)
        textField.placeholder = self.viewModel.inputPlaceholder
        textField.backgroundColor = .white
        self.view.addSubview(textField)
        self.textField = textField
        
        // ボタン
        let buttonW: CGFloat = self.view.frame.maxX * 0.8
        let buttonH: CGFloat = 80
        let buttonXPos: CGFloat = (self.view.frame.maxX / 2) - (buttonW / 2)
        let buttonYPos: CGFloat = textYPos + textH + 50 // ボタンのY座標をテキストフィールドの下に配置
        let buttonFrame = CGRect(x: buttonXPos, y: buttonYPos, width: buttonW, height: buttonH)
        let button = UIButton(frame: buttonFrame)
        button.setTitle(self.viewModel.buttonTitle, for: .normal)
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        self.view.addSubview(button)
        self.button = button
    }
    
    @objc func buttonTapped()
    {
        self.viewModel.buttonTapped(withText: self.textField!.text!)
    }
}
