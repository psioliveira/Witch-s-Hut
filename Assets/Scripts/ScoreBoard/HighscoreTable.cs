using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class HighscoreTable : MonoBehaviour
{
    private Transform container;
    private Transform template;
    private List<Transform> highscoreEntryTransformList;

    /// <summary>
    /// Control board
    /// </summary>
    private void Awake()
    {
        container = transform.Find("highscoreContainer");
        template = container.Find("highscoreTemplate");

        template.gameObject.SetActive(false);

        string jsonString = PlayerPrefs.GetString("highscoreTable");
        Highscores highscores = JsonUtility.FromJson<Highscores>(jsonString);

        for (int i = 0; i < highscores.highscoreEntryList.Count; i++)
        {
            for (int j = i; j < highscores.highscoreEntryList.Count; j++)
            {
                if (highscores.highscoreEntryList[j].score > highscores.highscoreEntryList[i].score)
                {
                    HighscoreEntry tmp = highscores.highscoreEntryList[i];
                    highscores.highscoreEntryList[i] = highscores.highscoreEntryList[j];
                    highscores.highscoreEntryList[j] = tmp;
                }
            }
        }
        highscoreEntryTransformList = new List<Transform>();

        foreach (HighscoreEntry highscoreEntry in highscores.highscoreEntryList)
        {
            CreateHighscoreEntryTransform(highscoreEntry, container, highscoreEntryTransformList);
        }
    }
   /// <summary>
   /// Create board
   /// </summary>
   /// <param name="highscoreEntry"></param>
   /// <param name="containers"></param>
   /// <param name="transformList"></param>
    private void CreateHighscoreEntryTransform(HighscoreEntry highscoreEntry, Transform containers, List<Transform> transformList)
    {   
        float templateHeight = 50f;

        Transform transform = Instantiate(template, containers);
        RectTransform rectTransform = transform.GetComponent<RectTransform>();
        rectTransform.anchoredPosition = new Vector2(0, -templateHeight * transformList.Count);
        transform.gameObject.SetActive(true);

        int rank = transformList.Count + 1;
        string rankString;

         switch (rank)
         {
            default:
            rankString = rank + "TH"; 
            break;

            case 1: rankString = "1ST";
            break;
            case 2: rankString = "2ND";
            break;
            case 3: rankString = "3RD";
            break;
        }

        transform.Find("posText").GetComponent<Text>().text = rankString;

        string name = highscoreEntry.name;
        transform.Find("nameText").GetComponent<Text>().text = name;

        int score = highscoreEntry.score;
        transform.Find("scoreText").GetComponent<Text>().text = score.ToString();

        transformList.Add(transform);
    }

    private void AddHighscoreEntry(int score, string name)
    {
        HighscoreEntry highscoreEntry = new HighscoreEntry{score = score, name = name};

        string jsonString = PlayerPrefs.GetString("highscoreTable");
        Highscores highscores = JsonUtility.FromJson<Highscores>(jsonString);

        highscores.highscoreEntryList.Add(highscoreEntry);
        string json = JsonUtility.ToJson(highscores);
        PlayerPrefs.SetString("highscoreTable" , json);
        PlayerPrefs.Save();
    }

    private class Highscores
    {
        public List<HighscoreEntry> highscoreEntryList;
    }

    [System.Serializable] private class HighscoreEntry
    {
        public int score;
        public string name;
    }
}
