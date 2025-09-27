# Cutscene Videos

Place your cutscene video files in this directory. The story system references these files:

- `act2_hedgehog.mp4` - Hedgehog adventure cutscene
- `act2_wisdom.mp4` - Gary's wisdom cutscene  
- `act3_new_life.mp4` - Career change ending
- `act3_home.mp4` - Home arrival ending

## Video Format
- Recommended: MP4 format
- Resolution: 360x640 (portrait mode)
- Keep file sizes reasonable for mobile deployment

## Adding New Cutscenes
1. Add video file to this directory
2. Reference it in `story_data.json` under the scene's `cutscene.video` property
3. The system will automatically handle playback and transitions
