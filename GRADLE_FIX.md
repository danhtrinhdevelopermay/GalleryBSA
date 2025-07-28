# Hướng Dẫn Sửa Lỗi Build APK trên GitHub Actions

## Các Vấn Đề Đã Sửa

### 1. Lỗi useProguard() Deprecated
```
Could not find method useProguard() for arguments [false] on BuildType
```

### 2. Lỗi Flutter Analyze (7 issues)
- Import cupertino.dart không cần thiết
- Null assertion operator (!) không cần thiết  
- VideoPlayerController.network deprecated
- Thư mục assets/images/ không tồn tại

### 3. Lỗi Flutter Test
```
Test directory "test" not found.
```

### 4. Lỗi Resource Shrinking
```
Removing unused resources requires unused code shrinking to be turned on
```

### 5. Lỗi Android Gradle Plugin Compatibility
```
java.lang.NoClassDefFoundError: com/android/build/OutputFile
```

### 6. Lỗi Flutter Analyze (dead_null_aware_expression)
```
The left operand can't be null, so the right operand is never executed
```

## Nguyên Nhân
Phương thức `useProguard()` đã bị deprecated trong các phiên bản Android Gradle Plugin mới hơn (từ phiên bản 3.4.0 trở lên).

## Giải Pháp Đã Áp Dụng

### 1. Sửa lỗi Flutter Code Issues
- **Loại bỏ import không cần thiết**: Xóa `import 'package:flutter/cupertino.dart'` từ main.dart và theme.dart
- **Cập nhật VideoPlayerController**: Thay `VideoPlayerController.network()` bằng `VideoPlayerController.networkUrl(Uri.parse())`
- **Sửa null assertion**: Thay `value!` bằng `value ?? 'available'` để tránh lỗi null safety
- **Tạo thư mục assets**: Tạo `assets/images/` với file .gitkeep
- **Tạo test cơ bản**: Thêm `test/widget_test.dart` để resolve lỗi test directory

### 2. Final Solution: Stable Legacy Stack
- **Ultimate Configuration**: AGP 7.1.3 + Gradle 7.3.3 + Java 8 + SDK 33
- **Root Cause**: Flutter 3.16.0 có incompatibility với AGP 7.2+ do OutputFile class changes
- **Gradle Wrapper**: Gradle 7.3.3 distribution (tương thích perfect với AGP 7.1.3)
- **GitHub Actions**: Java 8 để match với Flutter 3.16.0 build environment
- **SDK Downgrade**: compileSdk/targetSdk = 33 để tránh latest API conflicts
- **Gradle Properties**: Memory optimization và R8 disabled cho stability
- **ProGuard Rules**: Keep Android Build classes và Flutter framework
- **Java Compatibility**: JVM target 1.8 cho full compatibility với legacy stack

### 3. Tắt App Icon Generation
- **Comment flutter_icons config**: Tạm thời tắt cấu hình trong pubspec.yaml
- **Bỏ qua generate icons**: Comment bước này trong GitHub Actions workflow
- **Thêm flutter_launcher_icons**: Vào dev_dependencies để tránh lỗi package not found

### 4. Cập nhật file `android/app/build.gradle`
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
        shrinkResources false
        proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
    }
    debug {
        minifyEnabled false
        shrinkResources false
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