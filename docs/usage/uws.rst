Run-on-Demand
=============

The ExPRES code is available on https://voparis-uws-maser.obspm.fr/client
for run-on-demand requests. This server is implementing the `UWS
(Universal Worker Service Pattern) <https://www.ivoa.net/documents/UWS/>`_,
using the `OPUS (Observatoire de Paris UWS System)
<https://github.com/ParisAstronomicalDataCentre/OPUS>`_ framework. The service
can thus be used from the web interface, or through UWS command line clients,
such as the `uws-client <https://github.com/aipescience/uws-client>`_ (python
2) or one of its forks available at `uws-client
<https://github.com/aicardi-obspm/uws-client>`_ implementing Python 3 support.

Guest Access
------------
This type of access doesn't require to log in the server (no account). This allows guest
users to run the code openly. There are some limitation to the usage:

- Run data and results are visible to all
- Run duration is limited to 10 minutes
- Job can only use the *master* branch

Authenticated Access
--------------------
The authenticated access has be to requested to the `MASER team
<mailto:contact.maser@obspm.fr>`_. This type of access has the following features:

- Run data and results are only accessible to the user
- The maximum run duration is 3 hours.
- Any of the ExPRES git repository branches can be selected

Command Line Interface
----------------------
Guest Access
------------
The code can also be launch from a Command Line Interface, using the `uws client <https://github.com/aicardi-obspm/uws-client>`_ (more info and examples `here <https://aicardi.pages.obspm.fr/uws-cli/>`_).

You first need to download the uws client:

.. code-block::

    git clone https://github.com/aicardi-obspm/uws-client
    cd uws-client
    git checkout python3-support
    python setup.py install 

The following script gives a python example of how to run a simulation via the uws client, with a guest access:

**Example**

.. code-block::

    #−∗− coding : utf−8 −∗−
    from uws import UWS
    import time
   
    def uws_call_expres(FILE="example.json", FILE_EPHEM=None, Job_List=None, runID=None,
            LOOP=False, branch=None, LOGIN=None, executionDuration=None):
        FILE = "@"+FILE           
        SERVER = "voparis-uws-maser.obspm.fr"
        if runID == None:
            runID = "test_job"
        if LOGIN == None:
            LOGIN = ""
            TOKEN = ""
            Job_List = "ExPRES"
            branch = "master"
        if branch == None:
            branch = "master"
            Job_List = "ExPRES"
        if branch == "develop"
           Job_List = "ExPRES-dev"
           
        parameters = {'config':FILE, 'runId':runID, 'branch':branch}
        if FILE_EPHEM != None:
            FILE_EPHEM = "@"+FILE_EPHEM
            parameters['ephemeride'] = FILE_EPHEM
        if executionDuration != None:
            parameters['executionDuration'] = executionDuration

        print(parameters)

        uws_client = UWS.client.Client(url=f"https://{SERVER}/rest/{Job_List}", user=LOGIN,
            password=TOKEN)
     
        job = uws_client.new_job(parameters)
        job = uws_client.run_job(job.job_id)
     
        print(uws_client.get_phase(job.job_id))
        print(f"Job : {job.job_id}")
     
        if LOOP:
            while True:
                time.sleep(2)
                phase = uws_client.get_phase(job.job_id)
                if phase == UWS.models.JobPhases.COMPLETED:
                    print("Job completed")
                    break
                elif phase == UWS.models.JobPhases.ERROR or phase == UWS.models.JobPhases.ABORTED:
                    print("Job failed")
                    break
         
            job = uws_client.get_job(job.job_id)
            for result in job.results:
                filename = "./" + result.id
                print(f"Downloading {result.id}")
                uws_client.connection.download_file(str(result.reference), LOGIN, TOKEN, filename)


Then to run the simulation and retrieve the results:

.. code-block::

    from uws_call_expres import uws_call_expres
    uws_call_expres(FILE="example.json",LOOP=True)

Authenticated Access
--------------------
The above script is also valid for people with authenticated access. At this point, you must replace ``LOGIN=None``
and ``TOKEN=None`` with your login credentials (in text format). You will be able to access any of the
ExPRES git repository branches by replacing branch=None by the desired branch (e.g. ``branch="master"`` or
``branch="develop"``).
