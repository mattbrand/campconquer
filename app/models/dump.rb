class Dump
  def csv
    CSV.generate do |out|
      out << headers
      rows.each do |dump|
        dump.csv(out)
      end
    end
  end

  def html(out="")
    out << "    <table class='info-table'>"

    out << "    <tr>"
    headers.each do |name|
      out << "        <th>#{ name }</th>"
    end
    out << "  </tr>"

    rows.each do |row|
      row.html(out)
    end

    out << "    </table>"
    out
  end

end
