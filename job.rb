class Job
  attr_accessor :xml, :job_owner, :start_time, :running, :walltime_percent, :nodes_percent
  attr_accessor :job_owner, :job_name, :job_ID, :mem, :vmem, :walltime, :queue, :server, :err_path, :out_path, 
                :res_walltime, :res_nodes, :res_mem, :ses_ID, :shell_path_list, :euser, :egroup
    
  def self.get_jobs (user=nil)
    require "open3"
    require "nori"
    command = "/opt/torque/bin/qstat -f -x"
    command += " -u #{user}" if user
    raw_output, status = Open3.capture2e(command)
    xml = Nori.new.parse(raw_output)
    begin
      raw_jobs = xml["Data"]["Job"]
    rescue
      return []
    else
      jobs = raw_jobs.map do |raw_job| 
        job = Job.new
        job.xml = raw_job
        job.process_job
        job
      end
    end  
  end
    
  def initialize
  end
  
  def process_job
    @job_owner = @xml["euser"].split("@")[0]
    @job_name = @xml["Job_Name"]
    @job_ID = @xml["Job_Id"].split(".")
    
    @running = @xml["resources_used"]
    process_active_job if @running
        
    @queue = @xml["queue"]
    @server = @xml["server"]
        
    @err_path = @xml["Error_Path"]
    @out_path = @xml["Output_Path"]
        
    @res_walltime = @xml["Resource_List"]["walltime"]
    @res_nodes = @xml["Resource_List"]["nodes"]
        
    @session_ID = @xml["session_id"]
    @shell_path_list = @xml["Shell_Path_List"]
    @euser = @xml["euser"]
    @egroup = @xml["egroup"]
    
    process_percentages if @running
  end
  
  def process_active_job
    @mem = @xml["resources_used"]["mem"]
    @vmem = @xml["resources_used"]["vmem"]
    @walltime = @xml["resources_used"]["walltime"]
  end
  
  def process_percentages
    @walltime_percent = (@walltime.to_f/@res_walltime.to_f*100).to_i
  end
end
