# Kiểm tra trước khi gửi lại AppGallery

## Các thay đổi trong ứng dụng

- Lần đầu chạy phiên bản mới (kể cả khi cập nhật từ bản cũ), app nhắc đọc chính sách. Có thể đọc lại trong app; nội dung được đóng gói để đọc offline, gồm 18 ngôn ngữ và ghi `Power&volume` / `NGUYEN MINH THANH`.
- Lựa chọn ngôn ngữ được lưu. Lời nhắc quyền riêng tư, quyền trợ năng, điều khiển nhanh và nhiều thành phần giao diện có bản dịch cho 18 ngôn ngữ. Ngôn ngữ Arab dùng hướng chữ phải sang trái. Một số hướng dẫn nhà sản xuất ngoài tiếng Việt/Anh và Huawei tiếng Trung được thay bằng hướng dẫn chung, vì tên tùy chọn khác nhau theo dòng máy.
- Trước khi bật dịch vụ tiền cảnh có lời giải thích và nút xác nhận riêng. Từ chối thông báo trên Android 13+ thì app không khởi chạy dịch vụ này. Khi người dùng đã bật, app chỉ thử khôi phục sau khởi động/cập nhật nếu lựa chọn vẫn bật; hệ điều hành có thể từ chối. Việc cấp Trợ năng hoặc Quản trị viên thiết bị không đồng nghĩa đồng ý chạy dịch vụ tiền cảnh.
- Tích hợp banner Petal Ads tại đáy màn hình chính, không hiển thị ngoài app; không dùng banner giả hoặc quảng cáo toàn màn hình. Mã banner riêng: i3kcblwkv6. Chỉ tạo banner sau khi người dùng đồng ý riêng, có thể từ chối và thay đổi trong Cài đặt quảng cáo. Cấu hình chỉ yêu cầu quảng cáo không cá nhân hóa; điều này không có nghĩa là SDK không dùng định danh. Không thực hiện đăng nhập hay đăng ký.

## Trang web chính sách

`docs/privacy-policy-draft.html` chứa bản dự thảo 18 ngôn ngữ tương ứng với nội dung trong app. **Trang Vercel đang hoạt động chưa được cập nhật**: cần đối chiếu nội dung, tên app và email, sau đó cập nhật URL chính sách trong AppGallery Connect. Không coi bản dịch tự động hoặc tài liệu này là tư vấn pháp lý; nhà phát triển nên kiểm tra độ chính xác và yêu cầu pháp lý ở các khu vực phát hành.

## Kiểm thử thực tế

1. Cài mới, ngắt mạng và kiểm tra lời nhắc, mở chính sách Trung văn và đủ tên app/nhà phát triển. Mở lại chính sách từ màn hình chính.
2. Chọn các ngôn ngữ, bao gồm tiếng Trung và tiếng Arab; đóng/mở app để kiểm tra lựa chọn được lưu. Kiểm tra thông báo, quyền trợ năng, nút hệ thống, text lớn và màn hình nhỏ.
3. Tắt dịch vụ, cấp trợ năng/quản trị, khởi động lại máy và xác nhận dịch vụ vẫn tắt. Bật dịch vụ bằng xác nhận rõ ràng, thử khởi động lại và cập nhật app; kiểm tra thông báo, sau đó tắt và khởi động lại lần nữa. Kiểm tra cả trường hợp từ chối quyền thông báo, và thu hồi quyền thông báo sau khi đã bật rồi khởi động lại.
4. Kiểm thử P40 EMUI 11 và Mate 70 HarmonyOS 4.3 nếu có. OEM/hệ điều hành có thể hạn chế khởi động nền; không cam kết chạy liên tục.
5. So sánh fingerprint APK mới với chứng chỉ APK đã tải lên Huawei trước đây; kiểm tra versionCode trên cửa hàng trước khi phát hành. Việc thông qua kiểm thử tự động không bảo đảm Huawei chấp thuận lại mọi khu vực.

## Kiểm thử quảng cáo (bắt buộc trước phát hành)

- Build kiểm thử bằng `flutter build apk --release --dart-define=PETAL_ADS_TEST=true` (debug cũng mặc định dùng mã test Huawei). Không bấm quảng cáo thật để tự kiểm thử.
- Trên máy Huawei có HMS Core, thử cài mới và nâng cấp: từ chối lựa chọn quảng cáo thì không gọi tạo banner; đồng ý thì banner xuất hiện ở đáy màn hình chính; đổi lựa chọn để tắt/mở, khởi động lại và kiểm tra lưu. Thử ngoại tuyến, không có quảng cáo, màn hình nhỏ và xoay máy.
- Kiểm tra mã banner, fingerprint ký app thực tế và trạng thái ad unit; việc build thành công không bảo đảm phân phối hoặc tạo doanh thu.
- Bản thông báo và chính sách là dự thảo; rà lại với luật sư/người bản ngữ và yêu cầu consent/CMP của Huawei tại từng khu vực (đặc biệt EEA). Nút đồng ý tùy chỉnh chưa được xác nhận là CMP/TCF được Huawei chấp nhận. Rà merged manifest và SDK để xác minh việc khởi tạo/thu thập dữ liệu, đặc biệt trước khi có lựa chọn. Không phát hành cho đến khi đáp ứng yêu cầu pháp lý.
- Chính sách Vercel hiện chưa được cập nhật; bản trong `docs` chỉ là dự thảo. Điền chính xác biểu mẫu khai báo dữ liệu và SDK trong AppGallery.
