#!/usr/bin/env ruby
require_relative 'date_cleaner.rb'
require_relative 'department_cleaner.rb'
require_relative 'qualification_cleaner.rb'

# class to co-ordinate data cleaning
class MetadataCleaner
  def clean_metadata(key_metadata)
    clean_date(key_metadata)
    clean_department_names(key_metadata)
    # clean_qualifications(key_metadata)
  end

  def clean_date(key_metadata)
    if key_metadata.key?(:date)
      cleaner = DateCleaner.new
      date = key_metadata.fetch(:date)
      clean_date = cleaner.clean(date)
      key_metadata[:date] = clean_date unless clean_date.to_s.empty?
    end
    key_metadata
  end

  def clean_department_names(key_metadata)
    dept_keys_array = get_department_keys(key_metadata)
    dept_cleaner = DepartmentCleaner.new unless dept_keys_array.empty?
    dept_keys_array.each do |k|
      name = key_metadata.fetch(k)
      standard_name = dept_cleaner.clean_name(name) unless name.empty?
      key_metadata[k] = standard_name unless standard_name.nil?
    end
    key_metadata
  end

  def clean_qualifications(key_metadata)
    quals_keys_array = get_qualification_keys(key_metadata)
    quals_cleaner = QualificationCleaner.new unless quals_keys_array.empty?
    quals_keys_array.each do |q|
      qual_inf = key_metadata.fetch(q)
      standard_qname = quals_cleaner.clean(qual_inf) unless qual_inf.empty?
      key_metadata[q] = standard_qname unless standard_qname.nil?
    end
    key_metadata
  end

  def get_department_keys(key_metadata)
    # identify keys for both possible sets of sources (creatorX,publisherX)
    # return as array
    # https://www.safaribooksonline.com/library/view/ruby-cookbook/0596523696/ch05s15.html
    creators_hash = key_metadata.select { |k, _| k.to_s.include? 'creator' }
    publishers_hash = key_metadata.select { |k, _| k.to_s.include? 'publisher' }
    depts_hash = creators_hash.merge(publishers_hash)
    depts_hash.keys
  end

  def get_qualification_keys(key_metadata)
    # identify  keys relating to qualification names and levels, return as array
    quals_hash = key_metadata.select { |k, _| k.to_s.include? 'qualification' }
    quals_hash.keys
  end
end
