# Define Constants
$LOCALIZATION_KEY_MAGIC_DELIMITER = "_"
$FILEPATH = ".\locales.tsv"

# 
$lines = Get-Content -Path $FILEPATH -Encoding UTF8
$header = $lines[0].Split("`t")

# Header Reference:
# [0] == locale code
# [1] == is_localized
# [2...N] == localization fields

# A header like: [<text>] is interpreted as a section for the locale file.
# -- these fields' text for individual locales will not be considered

# Any other header value will be interpreted as a key value, which should need an associated localization.

# Clean up output path first
if (Test-Path -LiteralPath ".\locale\")
{
    Remove-Item -LiteralPath ".\locale\" -Force -Recurse
}
New-Item -ItemType Directory -Path ".\locale\"


# for each locale
for ($i = 1; $i -lt $lines.Count; $i++)
{
    $fields = $lines[$i].Split("`t")

    # check if it is defined
    if ($fields[1] -ne "true") { continue }
    
    $output_lines = ,""
    
    # for each translation string
    for ($j = 2; $j -lt $fields.Count; $j++)
    {
        $value = $fields[$j]

        if ($header[$j].Substring(0,1) -eq "[")
        {
            # we are defining a new area. like [mod-name]
            $output_lines += ""
            $output_lines += $header[$j]
            continue
        }

        # Normally the localization key will be the whole field
        $line_key = $header[$j]
        if ($line_key -contains $LOCALIZATION_KEY_MAGIC_DELIMITER)
        {
            # When the special character is present, we just use what comes before it.
            $line_key = $line_key.Split($LOCALIZATION_KEY_MAGIC_DELIMITER)[0]
        }
        
        $output_lines += ($line_key + "=" + $value)
    }

    $output_file = $output_lines -Join "`r`n"

    $output_folder = ".\locale\" + $fields[0] + "\"
    New-Item -ItemType Directory -Path $output_folder
    New-Item -Path ($output_folder + "locale.cfg") -Value $output_file
}
