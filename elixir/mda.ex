defmodule Mda do
  def to_html(mda_source) do
    mda_blocks = String.split(mda_source, "\n\n")

    html_content =
      for block <- mda_blocks do
        case String.at(block, 0) do
          "#" -> h(block)
          "[" -> image(block)
          "1" -> ol(block)
          "-" -> ul(block)
          "!" -> alert(block)
          "|" -> table(block)
          ">" -> sentence(block)
          "/" -> ynlist(block)
          "+" -> dialog(block)
          _ -> p(block)
        end
      end

    Enum.join(html_content, "\n")
  end

  defp h(block) do
    {h_type, unsigned_block} =
      cond do
        String.starts_with?(block, "######") -> {"h6", String.replace(block, "######", "")}
        String.starts_with?(block, "#####") -> {"h5", String.replace(block, "#####", "")}
        String.starts_with?(block, "####") -> {"h4", String.replace(block, "####", "")}
        String.starts_with?(block, "###") -> {"h3", String.replace(block, "###", "")}
        String.starts_with?(block, "##") -> {"h2", String.replace(block, "##", "")}
        true -> {"h1", String.replace(block, "#", "")}
      end

    {title, info} =
      if String.contains?(unsigned_block, "\n") do
        lines = String.split(unsigned_block, "\n")
        [title | infos] = lines
        {title, Enum.join(infos, " ")}
      else
        {unsigned_block, nil}
      end

    if info do
      "<#{h_type}>#{title}<span>#{to_span(info)}</span></#{h_type}>"
    else
      "<#{h_type}>#{title}</#{h_type}>"
    end
  end

  defp p(block) do
    "<p>#{to_span(block)}</p>"
  end

  defp image(block) do
    replaced_block = String.replace(block, "[", "")

    {link_text, alt_text} =
      case String.split(replaced_block, "]") do
        [_one_thing] -> {replaced_block, nil}
        [first, second] -> {first, second}
      end

    "<img src=\"#{link_text}\" alt=\"#{alt_text}\" />"
  end

  defp ol(block) do
    replaced_block = String.replace(block, "1.", "") |> String.replace("1)", "")

    li_lines =
      for line <- String.split(replaced_block, "\n") do
        "<li>#{line}</li>"
      end

    "<ol>\n#{to_span(Enum.join(li_lines, "\n"))}\n</ol>"
  end

  defp ul(block) do
    replaced_block = String.replace(block, "-", "", global: false)

    li_lines =
      for line <- String.split(replaced_block, "\n") do
        "<li>#{line}</li>"
      end

    "<ul>\n#{to_span(Enum.join(li_lines, "\n"))}\n</ul>"
  end

  defp alert(block) do
    {b_type, title, content, icon} =
      cond do
        String.starts_with?(block, "!!") ->
          replaced_block = String.replace(block, "!!", "")
          [first_line | other_lines] = String.split(replaced_block, "\n")

          icon = """
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="red" class="icon-size">
            <path stroke-linecap="round" stroke-linejoin="round" d="M12 9v3.75m9-.75a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9 3.75h.008v.008H12v-.008Z" />
          </svg>
          """

          {"warning", first_line, Enum.join(other_lines), icon}

        String.starts_with?(block, "!?") ->
          replaced_block = String.replace(block, "!?", "")
          [first_line | other_lines] = String.split(replaced_block, "\n")

          icon = """
          <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="currentColor" class="icon-size">
            <path stroke-linecap="round" stroke-linejoin="round"
              d="M9.879 7.519c1.171-1.025 3.071-1.025 4.242 0 1.172 1.025 1.172 2.687 0 3.712-.203.179-.43.326-.67.442-.745.361-1.45.999-1.45 1.827v.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9 5.25h.008v.008H12v-.008Z" />
          </svg>
          """

          {"question", first_line, Enum.join(other_lines), icon}

        String.starts_with?(block, "!") ->
          replaced_block = String.replace(block, "!", "")
          [first_line | other_lines] = String.split(replaced_block, "\n")

          icon = """
            <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="#005ac8" class="icon-size">
              <path stroke-linecap="round" stroke-linejoin="round"
                d="m11.25 11.25.041-.02a.75.75 0 0 1 1.063.852l-.708 2.836a.75.75 0 0 0 1.063.853l.041-.021M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Zm-9-3.75h.008v.008H12V8.25Z" />
            </svg>
          """

          {"info", first_line, Enum.join(other_lines), icon}
      end

    """
      <div class="#{b_type}">
        <div style="float:left;margin-right:1rem;">#{icon}</div>
        <div>
          <h3>#{title}</h3>
          <div>#{to_span(content)}</div>
        </div>
      </div>
    """
  end

  defp table(block) do
    replaced_block = String.slice(block, 1, String.length(block) - 1)
    [title | content_blocks] = String.split(replaced_block, "\n")

    content =
      for cb <- content_blocks do
        rows =
          for row <- String.split(cb, "|") do
            "<td>#{to_span(row)}</td>\n"
          end

        "<tr>#{rows}</tr>\n"
      end

    """
    <table>
      <tr><th colspan="2">#{title}</th></tr>
      #{content}
    </table>
    """
  end

  defp sentence(block) do
    [first | other_parts] = String.split(block, "\n")

    sentence_tag =
      if String.starts_with?(first, ">[") do
        replaced_first = String.slice(first, 2, String.length(block) - 1)
        [link | sentence_parts] = String.split(replaced_first, "]")
        sentence_text = Enum.join(sentence_parts, "]")

        """
        <a onclick="sentence_play('#{link}')" class="first-sentence">
          <span>&nbsp;<svg xmlns="http://www.w3.org/2000/svg" fill="yellow" viewBox="0 0 24 24" stroke-width="1.5" stroke="blue"
            style="width:1.2em;vertical-align:middle;display: inline-block;">
            <path stroke-linecap="round" stroke-linejoin="round"
            d="M19.114 5.636a9 9 0 0 1 0 12.728M16.463 8.288a5.25 5.25 0 0 1 0 7.424M6.75 8.25l4.72-4.72a.75.75 0 0 1 1.28.53v15.88a.75.75 0 0 1-1.28.53l-4.72-4.72H4.51c-.88 0-1.704-.507-1.938-1.354A9.009 9.009 0 0 1 2.25 12c0-.83.112-1.633.322-2.396C2.806 8.756 3.63 8.25 4.51 8.25H6.75Z" />
          </svg>
          #{to_span(sentence_text)}
        </a></br>
        """
      else
        replaced_first = String.slice(first, 1, String.length(block) - 1)

        """
        <span class="first-sentence">
          #{to_span(replaced_first)}
        </span></br>
        """
      end

    subsentence_tags =
      for i <- other_parts do
        """
        <span class="sub-sentence">
          #{to_span(i)}
        </span></br>
        """
      end

    """
    <div class="sentence">
      #{sentence_tag}
      #{subsentence_tags}
    </div>
    """
  end

  defp ynlist(block) do
    [title | items] = String.split(block, "\n")

    title_tag = """
      <h3>#{to_span(String.slice(title, 1, String.length(title) - 1))}</h3>
    """

    IO.inspect(items)
    IO.inspect(items)

    item_tags =
      for i <- items do
        # i = if i == "" do " " end
        case String.at(i, 0) do
          "+" ->
            """
            <p>
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="green"
                style="width:1em;vertical-align:middle;display:inline-block;">
                <path stroke-linecap="round" stroke-linejoin="round" d="M9 12.75 11.25 15 15 9.75M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z" />
              </svg>
              #{to_span(String.slice(i, 1, String.length(i) - 1))}
            </p>
            """

          "-" ->
            """
            <p>
              <svg xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24" stroke-width="1.5" stroke="red"
                style="width:1em;vertical-align:middle;display:inline-block;">
                <path stroke-linecap="round" stroke-linejoin="round" d="M18.364 18.364A9 9 0 0 0 5.636 5.636m12.728 12.728A9 9 0 0 1 5.636 5.636m12.728 12.728L5.636 5.636" />
              </svg>
              #{to_span(String.slice(i, 1, String.length(i) - 1))}
            </p>
            """

          "~" ->
            """
            <p>
              <span style="color:orange;font-size:1.5rem">~</span>
              #{to_span(String.slice(i, 1, String.length(i) - 1))}
            </p>
            """

          _ ->
            "</br>"
        end
      end

    """
      #{title_tag}
      #{item_tags}
    """
  end

  defp dialog(block) do
    replaced_block = String.replace(block, "\n+", "\nAE++") |> String.replace("\n-", "\nAE--")

    tags =
      for b <- String.split(replaced_block, ["\nAE-", "\nAE+"]) do
        if String.starts_with?(b, "+") do
          if String.starts_with?(b, "+[") do
            [main_line | sub_sentences] = String.split(remove(b, 2), "\n")
            [link | main_sentences] = String.split(main_line, "]")

            main_sentence =
              if main_sentences == [] do
                ""
              else
                Enum.join(main_sentences, "]")
              end

            sub_tag =
              for s <- sub_sentences do
                """
                  <i>#{to_span(s)}</i></br>
                """
              end

            """
              <div class="left-dialog-block">
                <a onclick="sentence_play('#{link}')" class="first-sentence">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="yellow" viewBox="0 0 24 24" stroke-width="1.5" stroke="blue"
                    style="width:1.2em;vertical-align:middle;display: inline-block;">
                    <path stroke-linecap="round" stroke-linejoin="round"
                    d="M19.114 5.636a9 9 0 0 1 0 12.728M16.463 8.288a5.25 5.25 0 0 1 0 7.424M6.75 8.25l4.72-4.72a.75.75 0 0 1 1.28.53v15.88a.75.75 0 0 1-1.28.53l-4.72-4.72H4.51c-.88 0-1.704-.507-1.938-1.354A9.009 9.009 0 0 1 2.25 12c0-.83.112-1.633.322-2.396C2.806 8.756 3.63 8.25 4.51 8.25H6.75Z" />
                  </svg>
                  #{to_span(main_sentence)}
                </a></br>
                #{sub_tag}
              </div>
            """
          else
            [main_sentence | sub_sentences] = String.split(remove(b), "\n")

            sub_tag =
              for s <- sub_sentences do
                """
                  <i>#{to_span(s)}</i></br>
                """
              end

            """
              <div class="left-dialog-block">
                <span class="first-sentence">
                  #{to_span(main_sentence)}
                </span></br>
                #{sub_tag}
              </div>
            """
          end
        else
          if String.starts_with?(b, "-[") do
            [main_line | sub_sentences] = String.split(remove(b, 2), "\n")
            [link | main_sentences] = String.split(main_line, "]")

            main_sentence =
              if main_sentences == [] do
                ""
              else
                Enum.join(main_sentences, "]")
              end

            sub_tag =
              for s <- sub_sentences do
                """
                  <i>#{to_span(s)}</i></br>
                """
              end

            """
              <div class="right-dialog-block">
                <a onclick="sentence_play('#{link}')" class="first-sentence">
                  <svg xmlns="http://www.w3.org/2000/svg" fill="yellow" viewBox="0 0 24 24" stroke-width="1.5" stroke="blue"
                    style="width:1.2em;vertical-align:middle;display: inline-block;">
                    <path stroke-linecap="round" stroke-linejoin="round"
                    d="M19.114 5.636a9 9 0 0 1 0 12.728M16.463 8.288a5.25 5.25 0 0 1 0 7.424M6.75 8.25l4.72-4.72a.75.75 0 0 1 1.28.53v15.88a.75.75 0 0 1-1.28.53l-4.72-4.72H4.51c-.88 0-1.704-.507-1.938-1.354A9.009 9.009 0 0 1 2.25 12c0-.83.112-1.633.322-2.396C2.806 8.756 3.63 8.25 4.51 8.25H6.75Z" />
                  </svg>
                  #{to_span(main_sentence)}
                </a></br>
                #{sub_tag}
              </div>
            """
          else
            [main_sentence | sub_sentences] = String.split(remove(b), "\n")

            sub_tag =
              for s <- sub_sentences do
                """
                  <i>#{to_span(s)}</i></br>
                """
              end

            """
              <div class="right-dialog-block">
                <span class="first-sentence">
                  #{to_span(main_sentence)}
                </span></br>
                #{sub_tag}
              </div>
            """
          end
        end
      end

    """
    <div class="dialog">
      #{tags}
    </div>
    """
  end

  defp remove(text, num) do
    String.slice(text, num, String.length(text) - 1)
  end

  defp remove(text) do
    String.slice(text, 1, String.length(text) - 1)
  end

  def to_span(text) do
    replaced_text =
      Regex.replace(~r/s\[\w*\]s/u, text, fn x, _ ->
        ham_x = String.replace(x, "s[", "") |> String.replace("]s", "")

        """
        <a onclick="new Audio('https://fly.storage.tigris.dev/suara/words/'+('#{ham_x}'.toLowerCase('tr-TR'))+'.ogg').play();"
        class="audio-text" style="text-align:justify">
          <span>&nbsp;<svg xmlns="http://www.w3.org/2000/svg" fill="yellow" viewBox="0 0 24 24" stroke-width="1.5" stroke="blue"
            style="width:1em;vertical-align:middle;display: inline-block;">
            <path stroke-linecap="round" stroke-linejoin="round"
            d="M19.114 5.636a9 9 0 0 1 0 12.728M16.463 8.288a5.25 5.25 0 0 1 0 7.424M6.75 8.25l4.72-4.72a.75.75 0 0 1 1.28.53v15.88a.75.75 0 0 1-1.28.53l-4.72-4.72H4.51c-.88 0-1.704-.507-1.938-1.354A9.009 9.009 0 0 1 2.25 12c0-.83.112-1.633.322-2.396C2.806 8.756 3.63 8.25 4.51 8.25H6.75Z" />
          </svg>
          #{ham_x}
          </span>
        </a>
        """
      end)

    replaced_text
    |> String.replace("b[", "<b>")
    |> String.replace("]b", "</b>")
    |> String.replace("i[", "<i>")
    |> String.replace("]i", "</i>")
    |> String.replace("u[", "<u>")
    |> String.replace("]u", "</u>")
    |> String.replace("]c", "</span>")
    |> String.replace("red[", "<span class=\"red-text\">")
    |> String.replace("green[", "<span class=\"green-text\">")
    |> String.replace("blue[", "<span class=\"blue-text\">")
    |> String.replace("yellow[", "<span class=\"yellow-text\">")
    |> String.replace("orange[", "<span class=\"orange-text\">")
    |> String.replace("purple[", "<span class=\"purple-text\">")
    |> String.replace("pink[", "<span class=\"pink-text\">")
    |> String.replace("brown[", "<span class=\"brown-text\">")
    |> String.replace("grey[", "<span class=\"grey-text\">")
    |> String.replace("1[", "<span class=\"color1-text\">")
    |> String.replace("2[", "<span class=\"color2-text\">")
    |> String.replace("3[", "<span class=\"color3-text\">")
    |> String.replace("4[", "<span class=\"color4-text\">")
    |> String.replace("5[", "<span class=\"color5-text\">")
    |> String.replace("6[", "<span class=\"color6-text\">")
    |> String.replace("7[", "<span class=\"color7-text\">")
    |> String.replace("8[", "<span class=\"color8-text\">")
    |> String.replace("9[", "<span class=\"color9-text\">")
    |> String.replace("]1", "</span>")
    |> String.replace("]2", "</span>")
    |> String.replace("]3", "</span>")
    |> String.replace("]4", "</span>")
    |> String.replace("]5", "</span>")
    |> String.replace("]6", "</span>")
    |> String.replace("]7", "</span>")
    |> String.replace("]8", "</span>")
    |> String.replace("]9", "</span>")
  end
end
