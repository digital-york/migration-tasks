#!/usr/bin/env ruby
class RiSearchQuery
# return appropriate ri search query for required records
def query(record_type)
  puts "getting search string for " + record_type
  case record_type
  when /thesis/
    search_string = thesis_search_string
  when /exam_paper/
    puts "getting exam_paper string"
    search_string = exam_paper_search_string
  end
  search_string
end

def exam_paper_search_string
  search_string = "select $object
  from <#ri>
  where ($object <info:fedora/fedora-system:def/model#hasModel> <info:fedora/york:CModel-ExamPaper>
  or $object <http://purl.org/dc/elements/1.1/type> 'http://dlib.york.ac.uk/type/ExamPaper'
  or $object <http://purl.org/dc/elements/1.1/type> 'Exam paper' or $object <http://purl.org/dc/elements/1.1/type> 'Exam papers')
  minus($object <http://purl.org/dc/elements/1.1/type> 'http://purl.org/eprint/type/Thesis' or $object <http://purl.org/dc/elements/1.1/publisher>  'ZigZag Education' )"

  search_string
end

def thesis_search_string
  search_string = "PREFIX dc: <http://purl.org/dc/elements/1.1/>
                          SELECT  ?record
                          WHERE {
                                  {
                                    ?record dc:type ?type .
                                    ?record dc:type 'http://purl.org/eprint/type/Thesis'
                                    OPTIONAL
                                    { ?record dc:publisher ?publisher . }
                                    FILTER regex (?type, 'aster')
                                    FILTER (!regex(?publisher,'oxford','i'))
                                    }UNION{
                                      ?record dc:type ?type .
                                      ?record dc:type 'Theses'.
                                      OPTIONAL
                                      {?record dc:publisher ?publisher .}
                                      FILTER regex (?type, 'aster')
                                      FILTER (!regex(?publisher,'oxford','i'))
                                      }UNION{
                                        ?record dc:type ?type .
                                        ?record <info:fedora/fedora-system:def/model#hasModel> <info:fedora/york:CModel-Thesis>
                                        FILTER regex (?type, 'aster')
                                      }
                                    }"
  search_string
end

end
