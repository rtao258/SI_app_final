require "open3"
require "nori"

class Job
  attr_accessor :xml, :job_owner, :start_time
  attr_accessor :job_owner, :job_name, :job_ID, :mem, :vmem, :walltime, :queue, :server, :err_path, :out_path, 
                :res_walltime, :res_nodes, :res_mem, :ses_ID, :shell_path_list, :euser, :egroup
    
  def self.get_jobs (user)
    command = "/opt/torque/bin/qstat -f -x"
    command += " -u #{user}"
    raw_output, status = Open3.capture2e(command)
    xml = Nori.new.parse(raw_output)
    raw_jobs = xml["Data"]["Job"]
    jobs = raw_jobs.map do |raw_job| 
      job = Job.new
      job.xml = raw_job
      job.process_job
      job
    end
  end
    
  def initialize
  end
  
  def process_job
    @job_owner = @xml["euser"].split("@")[0]
    @job_name = @xml["Job_Name"]
    @job_ID = @xml["Job_Id"].split(".")
    
    # these only work for some, probably only the active ones?
    #@mem = @xml["resources_used"]["mem"]
    #@vmem = @xml["resources_used"]["vmem"]
    #@walltime = @xml["resources_used"]["walltime"]
        
    @queue = @xml["queue"]
    @server = @xml["server"]
        
    @error_path = @xml["Error_Path"]
    @output_path = @xml["Output_Path"]
        
    @resource_walltime = @xml["Resource_List"]["walltime"]
    @resource_nodes = @xml["Resource_List"]["nodes"]
    @resource_mem = @xml["Resource_List"]["mem"]
        
    @session_ID = @xml["session_id"]
    @shell_path_list = @xml["Shell_Path_List"]
    @euser = @xml["euser"]
    @egroup = @xml["egroup"]
  end
end
