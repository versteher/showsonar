# Deploying to iPhone Wirelessly

## Prerequisites
1.  **Xcode**: Ensure you have Xcode installed.
2.  **Apple Developer Account**: You need a free or paid Apple Developer account signed in within Xcode.

## Initial Setup (One-time)
1.  **Connect via USB**: Connect your iPhone to your Mac using a USB cable.
2.  **Trust Computer**: Unlock your iPhone and tap "Trust" if prompted.
3.  **Enable Network Debugging in Xcode**:
    *   Open Xcode.
    *   Go to **Window > Devices and Simulators**.
    *   Select your iPhone from the left panel.
    *   Check the box **Connect via network**.
    *   Wait for a moment until a globe icon appears next to your phone icon in the list.
4.  **Disconnect USB**: You can now unplug the USB cable.

## Deploying
1.  **Find Device ID**:
    Run the following command in your terminal to list connected devices:
    ```bash
    flutter devices
    ```
    Look for your iPhone in the list. It should look something like:
    ```
    My iPhone (mobile) • <DEVICE_ID> • ios • ios-arm64
    ```

2.  **Run the App**:
    Use the `make` command with the device ID:
    ```bash
    make run-device DEVICE=<DEVICE_ID>
    ```

## Troubleshooting
*   **Device Not Found**: Ensure both your Mac and iPhone are on the same Wi-Fi network.
*   **Offline**: If the device shows as "offline" in `flutter devices`, try reconnecting via USB and toggling the "Connect via network" checkbox again.
