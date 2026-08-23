---
description: Bắt buộc sử dụng Native Tools để đọc/ghi file thay vì dùng lệnh Terminal (cat, Get-Content...) để tránh rác Prompt/Proceed.
---
# QUY TẮC BẮT BUỘC (CRITICAL RULE)
Để tránh việc người dùng phải ấn nút 'Proceed' liên tục khi AI dùng Terminal, bạn phải TUYỆT ĐỐI tuân thủ:

1. ĐỌC FILE: 
Tuyệt đối KHÔNG sử dụng \un_command\ với các lệnh như \cat\, \Get-Content\, \	ype\ để xem nội dung file. BẮT BUỘC sử dụng tool native là \iew_file\.

2. GHI/SỬA FILE: 
Tuyệt đối KHÔNG sử dụng \un_command\ với các lệnh như \echo\, \Set-Content\, \Out-File\, viết script Python/NodeJS để sửa file. BẮT BUỘC sử dụng các tool native là \write_to_file\ hoặc \eplace_file_content\.

3. TÌM KIẾM:
Ưu tiên sử dụng \grep_search\ hoặc \ind_by_name\ thay vì chạy \grep\ qua bash/PowerShell.

Việc tuân thủ quy tắc này là bắt buộc để cải thiện trải nghiệm người dùng (UX) trên Antigravity IDE.