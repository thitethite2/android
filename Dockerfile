# Use the official Codespaces base image
FROM mcr.microsoft.com/vscode/devcontainers/universal:linux

# Install dependencies for Android SDK and Emulator
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    wget \
    unzip \
    qemu-kvm \
    libvirt-daemon-system \
    libvirt-clients \
    bridge-utils

# Set environment variables for Android SDK
ENV ANDROID_SDK_ROOT /usr/local/android-sdk
ENV PATH ${ANDROID_SDK_ROOT}/cmdline-tools/tools/bin:$PATH
ENV PATH ${ANDROID_SDK_ROOT}/emulator:$PATH
ENV PATH ${ANDROID_SDK_ROOT}/platform-tools:$PATH

# Download and install Android SDK command line tools
RUN mkdir -p ${ANDROID_SDK_ROOT}/cmdline-tools && \
    cd ${ANDROID_SDK_ROOT}/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip -O tools.zip && \
    unzip tools.zip -d ${ANDROID_SDK_ROOT}/cmdline-tools && \
    rm tools.zip

# Install Android SDK packages
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-30" "system-images;android-30;default;x86_64" "emulator"

# Create an Android Virtual Device (AVD)
RUN echo "no" | avdmanager create avd -n test -k "system-images;android-30;default;x86_64"

# Expose necessary ports
EXPOSE 5554 5555

# Start the emulator
CMD ["emulator", "-avd", "test", "-no-window", "-gpu", "off", "-no-accel"]
