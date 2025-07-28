# Hướng Dẫn Sửa Lỗi Build APK trên GitHub Actions

## Vấn Đề
Lỗi build APK thất bại với thông báo:
```
Could not find method useProguard() for arguments [false] on BuildType
```

## Nguyên Nhân
Phương thức `useProguard()` đã bị deprecated trong các phiên bản Android Gradle Plugin mới hơn (từ phiên bản 3.4.0 trở lên).

## Giải Pháp Đã Áp Dụng

### 1. Cập nhật file `android/app/build.gradle`
**Trước khi sửa:**
```gradle
buildTypes {
    release {
        signingConfig signingConfigs.debug
        minifyEnabled false
        useProguard false  // ← Dòng này gây lỗi
        proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
    }
}
```

**Sau khi sửa:**
```gradle
buildTypes {
    release {
        signingConfig signingConfigs.debug
        minifyEnabled false
        // useProguard is deprecated, removed the line
        proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
    }
}
```

### 2. Giải Thích Chi Tiết
- **`useProguard false`**: Dòng này đã bị xóa vì không cần thiết
- **`minifyEnabled false`**: Vẫn giữ để điều khiển việc minify code
- **`proguardFiles`**: Vẫn giữ để cấu hình ProGuard rules (nếu cần)

## Các Bước Kiểm Tra Sau Khi Sửa

### 1. Build local để kiểm tra
```bash
flutter clean
flutter pub get
flutter build apk --release --split-per-abi
```

### 2. Kiểm tra GitHub Actions
- Push code lên repository
- Kiểm tra Actions tab để xem build có thành công không
- Download APK từ Artifacts nếu build thành công

## Thông Tin Phiên Bản Hiện Tại
- **Flutter**: 3.16.0
- **Android Gradle Plugin**: 7.3.0
- **Kotlin**: 1.7.10
- **Java**: 17
- **Min SDK**: 21
- **Target SDK**: 34

## Lưu Ý Bổ Sung
- Nếu vẫn gặp lỗi, có thể cần cập nhật thêm các phiên bản trong `android/build.gradle`
- Đảm bảo các dependency trong `pubspec.yaml` tương thích với phiên bản Flutter
- Kiểm tra xem có cần cập nhật Java version trong GitHub Actions không

## Liên Kết Tham Khảo
- [Android Gradle Plugin Release Notes](https://developer.android.com/studio/releases/gradle-plugin)
- [Flutter Android Build Documentation](https://docs.flutter.dev/deployment/android)
- [ProGuard/R8 Configuration](https://developer.android.com/studio/build/shrink-code)