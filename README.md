# Video Concatenation Script

A comprehensive bash script that processes and concatenates multiple video files from a directory into a single output video with consistent formatting, audio normalization, and optimized encoding settings.

## Features

- **Multi-format Support**: Converts various video formats to MP4
- **Audio Normalization**: Normalizes audio levels across all videos using FFmpeg's loudnorm filter
- **Consistent Formatting**: Standardizes frame rate, resolution, and encoding parameters
- **Smart Padding**: Maintains aspect ratios with letterboxing/pillarboxing
- **Progress Tracking**: Real-time progress indicators with colored output
- **Error Handling**: Graceful handling of invalid files with detailed logging
- **Runtime Tracking**: Reports total processing time
- **Automatic Cleanup**: Removes temporary files after processing

## Prerequisites

- **FFmpeg**: Must be installed and accessible in your PATH
  ```bash
  # macOS (using Homebrew)
  brew install ffmpeg

  # Ubuntu/Debian
  sudo apt update && sudo apt install ffmpeg

  # CentOS/RHEL
  sudo yum install ffmpeg
  ```

## Installation

1. Clone or download the script:
   ```bash
   git clone <repository-url>
   # or download concatenate-videos.sh directly
   ```

2. Make the script executable:
   ```bash
   chmod +x concatenate-videos.sh
   ```

## Usage

### Basic Usage
```bash
./concatenate-videos.sh <input_directory> <output_file>
```

### With Custom Resolution
```bash
./concatenate-videos.sh <input_directory> <output_file> <resolution>
```

### Examples

**Concatenate videos with default 1080p resolution:**
```bash
./concatenate-videos.sh /path/to/videos merged_video.mp4
```

**Concatenate videos with custom resolution:**
```bash
./concatenate-videos.sh /path/to/videos merged_video.mp4 1280:720
```

**Process videos from current directory:**
```bash
./concatenate-videos.sh . output.mp4
```

## Parameters

| Parameter         | Description                                     | Required | Default     |
| ----------------- | ----------------------------------------------- | -------- | ----------- |
| `input_directory` | Directory containing video files to concatenate | Yes      | -           |
| `output_file`     | Path and filename for the merged video output   | Yes      | -           |
| `resolution`      | Target resolution in format `width:height`      | No       | `1920:1080` |

## Processing Steps

The script follows a 6-step process to ensure optimal results:

1. **Directory Setup**: Creates temporary working directories
2. **Format Conversion**: Converts all input files to MP4 with H.264/AAC encoding
3. **Audio Normalization**: Applies loudnorm filter to balance audio levels
4. **Video Standardization**: Re-encodes with consistent settings:
   - Frame rate: 30 FPS
   - Resolution: Specified or default (1920x1080)
   - Video codec: H.264 with CRF 23
   - Audio: AAC, 48kHz, stereo
5. **Concatenation**: Merges all processed videos into final output
6. **Cleanup**: Removes temporary files and reports completion time

## Technical Specifications

### Video Processing
- **Video Codec**: H.264 (libx264)
- **Preset**: Fast (good balance of speed and quality)
- **CRF**: 23 (high quality)
- **Frame Rate**: 30 FPS
- **Aspect Ratio**: Preserved with padding when necessary

### Audio Processing
- **Audio Codec**: AAC
- **Sample Rate**: 48 kHz
- **Channels**: Stereo (2 channels)
- **Normalization**: EBU R128 loudness normalization

### File Handling
- **Input Formats**: Any format supported by FFmpeg
- **Output Format**: MP4 with FastStart flag for web optimization
- **Temporary Storage**: Creates unique working directory to avoid conflicts

## Output

The script provides colored, real-time feedback including:
- Step-by-step progress with file counts
- Individual file processing status
- Error messages for problematic files
- Total runtime upon completion

### Sample Output
```
Step 1: Converting all files to MP4...
  [1/5] Converting video1.avi to MP4...
  [2/5] Converting video2.mov to MP4...
  ...
Step 2: Normalizing audio for all converted videos...
  [1/5] Normalizing video1.mp4...
  ...
All done! Merged video saved as output.mp4
Total runtime: 2m 45s
```

## Error Handling

The script handles various error conditions gracefully:
- **Invalid video files**: Skipped with warning message
- **Encoding failures**: Logged and skipped
- **Missing dependencies**: Script exits with error message
- **Insufficient arguments**: Usage instructions displayed

## Troubleshooting

### Common Issues

**FFmpeg not found:**
```
command not found: ffmpeg
```
*Solution*: Install FFmpeg using your system's package manager.

**Permission denied:**
```
Permission denied: ./concatenate-videos.sh
```
*Solution*: Make the script executable with `chmod +x concatenate-videos.sh`.

**No space left on device:**
*Solution*: Ensure sufficient disk space for temporary files (approximately 2x the size of input videos).

**Memory issues with large files:**
*Solution*: Process smaller batches of videos or increase system memory.

## Performance Considerations

- **Processing time** depends on video count, duration, and system performance
- **Disk space** requirements: ~2x the total size of input videos for temporary files
- **Memory usage** scales with video resolution and duration
- **CPU usage** is intensive during re-encoding phases

## Limitations

- All videos are standardized to the same frame rate (30 FPS)
- Audio is converted to stereo (mono sources will be upmixed)
- Very large video collections may require significant processing time
- Custom audio/video codecs are not preserved (converted to H.264/AAC)

## License

This script is provided as-is for educational and practical use. Modify as needed for your specific requirements.

## Contributing

Feel free to submit issues or improvements. Common enhancement areas:
- Additional output format support
- Configurable encoding parameters
- Resume capability for interrupted processing
- GPU acceleration support
