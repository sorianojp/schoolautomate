<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector, java.io.*" %>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
}
    TABLE.thinborder {
		border-top: solid 1px #000000;
    	border-right: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 11px;	
    }

    TD.thinborder {
	    border-left: solid 1px #000000;
    	border-bottom: solid 1px #000000;
		font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
		font-size: 11px;
    }
    TD.thinborderBOTTOM {
   	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }
    TD.thinborderTOPBOTTOM {
   	border-top: solid 1px #000000;
   	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }

-->
</style>
</head>
<script>
	function CallOnLoad() {
		document.all.processing.style.visibility='hidden';	
		document.bgColor = "#FFFFFF";
	}
	var strMaxPage = null;
	var objLabel   = null;
	function ShowProgress(pageCount, maxPage) {
		if(objLabel == null) {
			objLabel = document.getElementById("page_progress");
			strMaxPage = maxPage;
		}
		if(!objLabel)
			return;
		var strShowProgress = pageCount;//+" of "+strMaxPage;
		objLabel.innerHTML = strShowProgress;
	}

</script>
<body topmargin="0" bottommargin="0" onLoad="CallOnLoad();" bgcolor="#CCCCCC">

<!-- Printing information. -->
<div id="processing" style="position:absolute; top:0px; left:0px; width:250px; height:50px;  visibility:visible">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL">
      <tr>
            <td align="center" class="v10blancong" bgcolor="#FFCC66">
			<p style="font-size:12px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait...
			<br> <font color='red'>Loading Page <label id="page_progress"></label></font></p>
			
			<!--<img src="../../../Ajax/ajax-loader2.gif">--></td>
      </tr>
</table>
</div>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strErrMsg = null;
	String strTemp = null;
	String strDegType = null;//0-> uG,1->doctoral,2->college of medicine.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-print class list","class_list_cit_print.jsp");
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		//ErrorLog.logError(exp,"admission_application_sch_veiwall.jsp","While Opening DB Con");

		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3">
		Error in opening connection</font></p>
		<%
		return;
	}
Vector vSecDetail = null;
Vector vClassList = null;
Vector vSubSecRef = null;

Vector vDeanInfo = null;


String[] astrConvertSem = {"SUMMER","1ST SEM","2ND SEM","3RD SEM"};
String strSYTerm = astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))] +", "+WI.fillTextValue("sy_from")+" - "+
	WI.fillTextValue("sy_to").substring(2);



ReportEnrollment reportEnrl= new ReportEnrollment();
vSubSecRef = reportEnrl.getClassListSubSecRefCIT(dbOP, request);
if(vSubSecRef == null)
	strErrMsg = reportEnrl.getErrMsg();



if(strErrMsg != null){
	dbOP.cleanUP();


%>
<table width="100%" border="0" >
    <tr>
      <td width="100%"><div align="center"><%=strErrMsg%></div></td>
    </tr>
</table>
<%return;}

String strDateTimePrinted = WI.formatDateTime(null, 5);

int iRowsPerPg = 60;//Integer.parseInt(WI.fillTextValue("rows_per_pg"));
int iRowsPrinted = 0; int iIndexOf = 0;

String strSubSecIndex = null;
String strSubCode     = null;
String strSubName     = null;
String strSection     = null;
String strIsLec       = null;
String strTimeRoomNo  = null;

String strCollegeCode = null;

String[] astrIsLec = {"Lec","Lab"};
int iPageNo = 0;int iCount;


Vector vScheduleDtls = null;
Vector vLabSchDtls   = null;

String strLecTime = null;
String strLabTime = null;
String strLecFac  = null;
String strLabFac  = null;
//System.out.println(vSubSecRef);
boolean bolForcePrint = false;
int iCount2 = 0; 
String strFontSize = "";

//get inster Dir.

strTemp = "select prop_val from read_property_file where prop_name = 'installdir'";
String strInstallDir = dbOP.getResultOfAQuery(strTemp, 0);
if(!strInstallDir.endsWith("/"))
	strInstallDir = strInstallDir +"/";
strInstallDir = strInstallDir + "download/";


//write excel Sheet here.. 
wtexcel.ClassRecordCIT WTE = new wtexcel.ClassRecordCIT();
//boolean bolIsPE = false;
String strTemplateToUse = null;
	strTemplateToUse = "class_list_neu.xls";
	iRowsPerPg = 300;

	File fCopy = new File(strInstallDir+"neu/"+strTemplateToUse);
	File fCopyDest = new File(strInstallDir+strTemplateToUse);
	if(!fCopyDest.exists()) {
		byte[] bByte = new byte[8000];
		BufferedInputStream bIn = new BufferedInputStream(new FileInputStream(fCopy));
		BufferedOutputStream bOut = new BufferedOutputStream(new FileOutputStream(fCopyDest));
		while(bIn.read(bByte, 0, 8000) > -1) {
			//System.out.println("I am writing.");
			bOut.write(bByte, 0, 8000);
		}
		bOut.flush();
		bOut.close();
		bIn.close();
	}

while(vSubSecRef.size() > 0) {
	Thread.sleep(300);
	//System.out.println("Wake up: 300ms");
	strSubSecIndex = (String)vSubSecRef.remove(0);
	strSubCode     = (String)vSubSecRef.remove(0);
	strSubName     = (String)vSubSecRef.remove(0);
	if(strSubName != null && strSubName.length() > 40) 
		strSubName = strSubName.substring(0,40);
				
	strSection     = (String)vSubSecRef.remove(0);
	strIsLec       = (String)vSubSecRef.remove(0);
	vScheduleDtls  = (Vector)vSubSecRef.remove(0);
	//System.out.println("Printing : "+vScheduleDtls);
	strLecTime = null;strLabTime = null;strLecFac  = null;strLabFac  = null;
	
	strCollegeCode = "select college.c_code from e_sub_section join college on (college.c_index = offered_by_college) where sub_sec_index = "+strSubSecIndex;
	strCollegeCode = dbOP.getResultOfAQuery(strCollegeCode, 0);
	if(strCollegeCode == null)
		strCollegeCode = "";
	else
		strCollegeCode = strCollegeCode+ "-";
	
	if(vScheduleDtls != null && vScheduleDtls.size() > 0) {
		vLabSchDtls    = (Vector)vScheduleDtls.remove(0);
		strLecFac = (String)vScheduleDtls.remove(0);
		for(int p = 0; p<vScheduleDtls.size(); p+=3) {
        	if(strLecTime == null)
				strLecTime = (String)vScheduleDtls.elementAt(p + 2) + " Room: " + (String)vScheduleDtls.elementAt(p);
			else	
				strLecTime +=", "+ (String)vScheduleDtls.elementAt(p + 2) + " Room: " + (String)vScheduleDtls.elementAt(p);
		}
		if(vLabSchDtls != null && vLabSchDtls.size() > 0) {
			strLabFac = (String)vLabSchDtls.remove(0);
			for(int p = 0; p<vLabSchDtls.size(); p+=3) {
				if(strLabTime == null)
					strLabTime = (String)vLabSchDtls.elementAt(p + 2) + " Room: " + (String)vLabSchDtls.elementAt(p);
				else	
					strLabTime +=", "+ (String)vLabSchDtls.elementAt(p + 2) + " Room: " + (String)vLabSchDtls.elementAt(p);
			}
		}
	}
	

	vClassList = reportEnrl.getClassListDetailCIT(dbOP, strSubSecIndex, WI.fillTextValue("sy_from"), WI.fillTextValue("semester"));
	if(vClassList == null || vClassList.size() == 0) {
		continue;
	}
	if(iCount2++ > 0)
		bolForcePrint = true;
	iCount = 0;
%>
<script language="javascript">
	ShowProgress(<%=++iPageNo%>);
</script>
<%
	//create excel sheet here. 

	WTE.setPath(strInstallDir, strTemplateToUse);
	
	
	for(int i =0; i < vClassList.size();) {
		//do not print if rows exceeds max row size.

		System.out.println("starting to write: "+strCollegeCode+strSubCode+"-"+strSection+".xls");
		WTE.WriteClose();
		WTE.createFile(strCollegeCode+strSubCode+"-"+strSection+".xls");
	
		/** no where to write this**/
		WTE.writeData(strSubCode, 5,1);
		WTE.writeData(strSubName, 6,1);
		WTE.writeData(strSYTerm, 4,1);
		
		strTemp = strLecTime;
		if(strLabTime != null)
			strTemp = strTemp + " (LAB) "+strLabTime;
		
		WTE.writeData(strTemp, 8,1);
		WTE.writeData(strSection, 7,1);
		
		WTE.writeData(strLecFac, 9,1);
		
%>
<!--		
		<table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
				<tr align="center">
					<td width="2%" class="thinborder" height="30">No.</td>
					<td width="34%" class="thinborder">Name</td>
					<td width="10%" class="thinborder">Course-Yr</td>
				    <td width="3%" class="thinborder">&nbsp;</td>
				    <td width="3%" class="thinborder">&nbsp;</td>
				    <td width="3%" class="thinborder">&nbsp;</td>
				    <td width="3%" class="thinborder">&nbsp;</td>
				    <td width="3%" class="thinborder">&nbsp;</td>
				    <td width="3%" class="thinborder">&nbsp;</td>
				    <td width="3%" class="thinborder">&nbsp;</td>
				    <td width="3%" class="thinborder">&nbsp;</td>
				    <td width="3%" class="thinborder">&nbsp;</td>
				    <td width="3%" class="thinborder">&nbsp;</td>
				    <td width="3%" class="thinborder">&nbsp;</td>
				    <td width="3%" class="thinborder">&nbsp;</td>
				    <td width="3%" class="thinborder">&nbsp;</td>
				    <td width="3%" class="thinborder">&nbsp;</td>
				    <td width="3%" class="thinborder">&nbsp;</td>
				    <td width="3%" class="thinborder">&nbsp;</td>
				    <td width="3%" class="thinborder">&nbsp;</td>
				    <td width="3%" class="thinborder">&nbsp;</td>
				</tr>
				<%
				
				for(iRowsPrinted = 0; i < vClassList.size(); i += 7, ++iRowsPrinted) {
					//if(iRowsPerPg <= iRowsPrinted)
					//	break;
					
					//write to excel here.
					
					//System.out.println("iRowsPrinted: "+vClassList.elementAt(i));
					//System.out.println("iRowsPrinted: "+vClassList.elementAt(i + 1));
					
					WTE.writeData((String)vClassList.elementAt(i), iRowsPrinted+12,0);//id
					WTE.writeData((String)vClassList.elementAt(i + 1), iRowsPrinted+12,1);//name
					strTemp = (String)vClassList.elementAt(i + 3) + WI.getStrValue((String)vClassList.elementAt(i + 4), "-", "","") + WI.getStrValue((String)vClassList.elementAt(i + 5), "-", "","");
					WTE.writeData(strTemp, iRowsPrinted+12,3);//course-year.
					
					WTE.writeData((String)vClassList.elementAt(i + 2), iRowsPrinted+12,2);//gender
					
					%>
				<%}%>
				
			</table>
			
			
		
	<%}//outer for loop.%>
-->		
	
    <%}//while(vSubSecRef.size() > 0) 
WTE.WriteClose();
%>
To Get the files go to SA URL/download/

</body>
</html>
<%
dbOP.cleanUP();
%>