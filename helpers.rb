def record_counter ()
  Records.all.count
end

def new_records_counter()
  Records.find_by(sent: '').count
end

def new_records_array()
  Records.find_by(sent: '')
end

def record_sender(target_object, package)
    #TODO: Add bulk upload checker and logic here
    #TODO: Need to submit the creates in groups of 200 if not using bulk

    if package.count < 5000 
      if package.each do { |item|
         salesforce_rest.create(item)
         puts "Sending #{item}"
       }
       package.each do {|item|
         item.sent == true
         item.save!
         puts "Marked #{item} as saved"
       }
     else
       #TODO: fix this - we need proper error handling. According to the Bobj's docs, if you run into an error, just retry the entire set of creates. Not sure how to do this.
       puts "Ran into an error, restarting the send"
       record_sender(package)
     end
   else
     paged = package.paginate(:per_page => 5000)
     paged.each do { |page|
       result = salesforce_bulk.create(target_object, page)
       puts "result is: #{result.inspect}"
       }
end