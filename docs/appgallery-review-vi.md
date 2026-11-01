# Kiểm tra trước khi gửi lại AppGallery

## Các thay đổi trong ứng dụng

- Lần đầu chạy phiên bản mới (kể cả khi cập nhật từ bản cũ), app nhắc đọc chính sách. Có thể đọc lại trong app; nội dung được đóng gói để đọc offline, gồm 18 ngôn ngữ và ghi `Power&volume` / `NGUYEN MINH THANH`.
- Lựa chọn ngôn ngữ được lưu. Lời nhắc quyền riêng tư, quyền trợ năng, điều khiển nhanh và nhiều thành phần giao diện có bản dịch cho 18 ngôn ngữ. Ngôn ngữ Arab dùng hướng chữ phải sang trái. Một số hướng dẫn nhà sản xuất ngoài tiếng Việt/Anh và Huawei tiếng Trung được thay bằng hướng dẫn chung, vì tên tùy chọn khác nhau theo dòng máy.
- Trước khi bật dịch vụ tiền cảnh có lời giải thích và nút xác nhận riêng. Từ chối thông báo trên Android 13+ thì app không khởi chạy dịch vụ này. Khi người dùng đã bật, app chỉ thử khôi phục sau khởi động/cập nhật nếu lựa chọn vẫn bật; hệ điều hành có thể từ chối. Việc cấp Trợ năng hoặc Quản trị viên thiết bị không đồng nghĩa đồng ý chạy dịch vụ tiền cảnh.
- Đã gỡ banner quảng cáo giả lập (bản này không tích hợp SDK quảng cáo). Không thực hiện đăng nhập hay đăng ký.

## Trang web chính sách

`docs/privacy-policy-draft.html` chứa bản dự thảo 18 ngôn ngữ tương ứng với nội dung trong app. **Trang Vercel đang hoạt động chưa được cập nhật**: cần đối chiếu nội dung, tên app và email, sau đó cập nhật URL chính sách trong AppGallery Connect. Không coi bản dịch tự động hoặc tài liệu này là tư vấn pháp lý; nhà phát triển nên kiểm tra độ chính xác và yêu cầu pháp lý ở các khu vực phát hành.

## Kiểm thử thực tế

1. Cài mới, ngắt mạng và kiểm tra lời nhắc, mở chính sách Trung văn và đủ tên app/nhà phát triển. Mở lại chính sách từ màn hình chính.
2. Chọn các ngôn ngữ, bao gồm tiếng Trung và tiếng Arab; đóng/mở app để kiểm tra lựa chọn được lưu. Kiểm tra thông báo, quyền trợ năng, nút hệ thống, text lớn và màn hình nhỏ.
3. Tắt dịch vụ, cấp trợ năng/quản trị, khởi động lại máy và xác nhận dịch vụ vẫn tắt. Bật dịch vụ bằng xác nhận rõ ràng, thử khởi động lại và cập nhật app; kiểm tra thông báo, sau đó tắt và khởi động lại lần nữa. Kiểm tra cả trường hợp từ chối quyền thông báo, và thu hồi quyền thông báo sau khi đã bật rồi khởi động lại.
4. Kiểm thử P40 EMUI 11 và Mate 70 HarmonyOS 4.3 nếu có. OEM/hệ điều hành có thể hạn chế khởi động nền; không cam kết chạy liên tục.
5. So sánh fingerprint APK mới với chứng chỉ APK đã tải lên Huawei trước đây; kiểm tra versionCode trên cửa hàng trước khi phát hành. Việc thông qua kiểm thử tự động không bảo đảm Huawei chấp thuận lại mọi khu vực.
