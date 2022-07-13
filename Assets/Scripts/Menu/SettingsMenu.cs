using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Audio;

public class SettingsMenu : MonoBehaviour
{
    public AudioMixer audioMixer;
    public AudioMixer audioMixerSfx;

    public void SetVolume (float volume)
    {
        audioMixer.SetFloat("Volume", volume);
        audioMixer.SetFloat("Enemy", volume);
        audioMixer.SetFloat("Master", volume);
        audioMixer.SetFloat("Player", volume);
    }

    public void SetFullscreen (bool isFullscreen)
    {
        Screen.fullScreen = isFullscreen;
    }

    public void SetQuality (int qualityIndex)
    {
        QualitySettings.SetQualityLevel(qualityIndex);
    }
}
