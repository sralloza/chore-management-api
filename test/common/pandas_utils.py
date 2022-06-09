import re


def normalize_df(df):
    df.index.name = ""
    df_str = str(df)
    return re.sub("\n\\s+\n", "\n\n", df_str)
