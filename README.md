##sentimental-tweets-map##


**Sentiment Analysis of Twitter Posts About Group Emotion Change Pattern**

This is an academic project done in the middle of May, 2011.

The interest of this project is in how Hopkins student’s emotion changes in the first day before the final exam week,
and to determine how latest news and incidence affect the emotion change.

- **robot.pl** a crawler, got tweets from search.twitter.com and label them with a time stamp representing when they are tweeted.

- **TrainingData.pl** a crawler, got tweets from search.twitter.com with labels indicating their attitudes (positive/negative), as our original training data.

- **analysis.pl** Added weights to words according to the frequency to get two emotion 'score' (positive/negative) for any given time, then group the score by hour.


Now I am trying to reuse the code for another project since I found the sentiment analysis still an interesting topic to me. So this project probably will transform to something cooler soon. I just don't know yet. :P
