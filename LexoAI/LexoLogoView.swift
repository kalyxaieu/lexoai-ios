import SwiftUI
import UIKit

private enum LexoLogoAsset {
    static let image: UIImage? = {
        guard let data = Data(base64Encoded: """
/9j/4AAQSkZJRgABAQAAAQABAAD/2wBDAAoHBwgHBgoICAgLCgoLDhgQDg0NDh0VFhEYIx8lJCIfIiEmKzcvJik0KSEiMEExNDk7Pj4+JS5ESUM8SDc9Pjv/2wBDAQoLCw4NDhwQEBw7KCIoOzs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozv/wAARCACAAIADASIAAhEBAxEB/8QAHAABAAIDAQEBAAAAAAAAAAAAAAUGAwQHCAIB/8QAORAAAQQBAgMFBQUHBQAAAAAAAQACAwQFESEGEjETQVFhgQciQnGxFDJikaEVI3OTwdHhUnKCkvD/xAAaAQEAAgMBAAAAAAAAAAAAAAAABQYBAwQC/8QALBEAAgICAAUDAwMFAAAAAAAAAAECAwQRBRIhMVEyQZETFHEGYeGBobHR8P/aAAwDAQACEQMRAD8A7KiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIiIAiIgCIiAIte5eq4+uZ7czIox3uPXyHiVUbvtBPaFtCk0sB2fM46n0HT810U4tt/oRshVOfZF2RUqj7QCZA2/SDWH44XE6eh/urdTvVr8AnqzNljPe09Pn4Jdi20+tGJQlHuZ0RFzngIiIAiIgCIiAIixWbEVSvJYneGRxjmc49wWUm3pBLfRGVVjOca1MfzQUeW1YGxIPuMPme/wCQVbz/ABXcyhfDC51ep05GnRzx+I/0VYe/RT+Jwpeq74/2SFeJyrdnwbmRylvJ2O3uTulf3a9GjwA7lqtfqsHPqVguZOvjtGykmUjmEbRuR4/JTygorSRtnNRXhErHuvqDiavhbPaQ3+SYdWxe9r5EDb81TbWXuX9Wc3ZRH4GHr8z3rFDB5LDpU1qXYhsjLXsdqwftNw2QLILsv2WY7B72lsbvXu9Vc2ua9oc0gtI1BB2IXnCGv5K48LcR5DBPZEHump6+9A47Afh8D+ihsvhEdc1L6+CNXEoxlqzsdfRYalqG7VjswO5o5G6tKzKuNNPTJVNSW0ERFgyEREAVM47vu5oMe06NI7WTz30A+pVzXP8Ajca5wfwG/UqQ4dFSyFv2OzDSdvX2KpM7RMdiruaufZqUXO8DVxJ0aweJKhs5no6j3Vqukk42c7q1n9yut+znGso8HU5z79i8wWZ5D1cXdPQDQaKwZeX9tVzJdWb8jISekfOD4CoY7lmvEXbA30cP3bT5Dv8AX8lL5nhvEcQVRXyVKOYNGjH6aPj/ANrhuFuW79Ogxr7lqGs1zuVrppAwE+A1X1YtV6ld1izPHDC0aukkeGtHqVWJ5F9k1ZJvft/BHSk5dzk2d9lF3Hl0+HkN6Ab9k7QStH0d+h8lVWU5IpDHJG5j2nRzXDQg+YXoRtmB9b7S2aN0Bbz9qHAt5fHXpoou5i8HxRWE/wC4sjoyzA8Ej/kOvyKl8bjFkFq5bXkjsnElNbrfU4/Xq9NlK1q3TZTeZ4WdgYjadO19TmDTIdizU6Dm7hvtqsEMIGmyk3lQtjzQe0UvNdtMuWxaZZuDLDmNmpuOrdO0YPDuP9FalUeFm8uSP8I/UK3KsZqX1m17lp4FbKzDXN7NoIiLjJoIiIAuV+1bIvoXWshOk88LWtP+kb6n/wB4rqi5H7X6j/29QskHs5KxaD+IO3/QhSvCIqWUk/DN9EnGT14OZtg7yvQfs9yMGQ4Mx4icOetEIJW97XN23+Y0PquFdnoFv4fPZPh20bGMsmJzho9hHMx48x3/AFVlz8B5NPLF6a6o8WaR2HjbgiPjJlTmvvqPqudoQznDg7TXbUb7DdZuIODoc5wpBgRclgbWEfZTEc5JYNBzDbXZVrCe2GjKWw5yq6o/p28IL4/UfeH6q/4/J0crWFnH24bUJ+OJ4cPXwVVujl43LGfRR7eDWpb7ENX4Ogg4HPC5uSujdE5hn00dqXc2oHhr3eC/eDOEmcIYuWmLjrT5pe0e8s5ADoBoBqfBT008VeMyTSsiYOrnuDQPUqu5Hj7B0tWwyvuSDugb7v8A2O35arXD7m9OEE2m9v8AJ4nbGC3J6M3HU0MPBmTE+hEkBjaD3udsP1+i4/gc/NipW17TnS0ydN9zF5jy8lN8TcR3eJZWiVohrRnWOBp138Se8quTVNuiseFhOmjls7vr+Cu519OU+Rrcf+6nXuGeV17nYQ5roiQR0I2VqVA9lz5JsfIH6kVSYwfI6ED6q/qu5y5b3HwdnBaXTjcr8sIiLiJkIiIAoPizhuLibEGqXCOeM88EhGzXeB8j0P8AhTiLZVZKqanB6aMptPaPPGUxF7DWXV8hWfA8HYuHuu8wehCj2wyWZBFBG+aR3RkbS4n0C9KSwxTsLJo2SMPwvaCPyK13Mo4mrNZbDDXijYXvMbA3YbnorJH9QNx069y/P8Hme5Hna5w7kq0rYrlc1HuaHcsuzgD01HUeq2MTUlw9sW6l6zFOPiieWa+R06j5qTyuTlyuTsX5tnTPLtNfujuHoNApLG8HZ3JVm2YKXLE77rpXhnMPEA76KYnKEa08hpf4/ucdra6Q6sj7Ny5kZe0u2ZbDvGR5dp8vBfscPMrDHwFnh1rxfzmrch4IzDfvQx/zQuaWbjxWozXyiAyYZMn0g3/Rldjqajovr9myWJGxQxufI86Na0bkq50+DLhI7d8UTe/Q8xVmxmEp4sc0LOaUjQyu3d/hR93FK4el7ZoxeHZV09zXLH9+/wAGtwtghgMO2s4gzSO7SYjpzHuHkBoFMoirdk5WSc5d2XCEI1xUY9kERF4PYREQBERAFVuPYsrdxUOOxdSSf7VLpK5nRrRuAT3AnTfyVpRbqLfo2KxLegyncNez+pi+S1kuS3bG4bprHGfIfEfM/kriiLN+RZfPnse2YSS7BERaDIREQBERAEREAREQBERAEREAREQBERAEREAREQBERAf/2Q==
""") else { return nil }
        return UIImage(data: data)
    }()
}

struct LexoLogoView: View {
    var body: some View {
        Group {
            if let image = LexoLogoAsset.image {
                Image(uiImage: image).resizable().scaledToFit()
            } else {
                ZStack {
                    RoundedRectangle(cornerRadius: 22).fill(
                        LinearGradient(colors: [Color(red: 0.43, green: 0.34, blue: 0.91), Color(red: 0.19, green: 0.15, blue: 0.48)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    Image(systemName: "sparkles").font(.system(size: 38, weight: .medium)).foregroundStyle(.white)
                }
            }
        }
        .accessibilityLabel("Logo Lexo AI")
    }
}
