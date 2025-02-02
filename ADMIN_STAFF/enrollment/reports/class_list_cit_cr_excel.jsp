<%
String strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null) 
	strSchCode = "";
if(strSchCode.startsWith("UC")){%>
	<jsp:forward page="./class_list_uc_cr_excel.jsp" />
<%}%>

<!-- 
	Class Record printing.. 
-->
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



<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector" %>
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
else {
	vDeanInfo = reportEnrl.getClassListDeanInfo(dbOP, request);
}
if(vDeanInfo == null)
	vDeanInfo = new Vector();



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

while(vSubSecRef.size() > 0) {
	Thread.sleep(300);

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
	if(vClassList.size()/7 > 72) {
		strTemplateToUse = "class_record_72plus.xls";
		iRowsPerPg = 300;
	}
	else if(vClassList.size()/7 > 60) {
		strTemplateToUse = "class_record_60plus.xls";
		iRowsPerPg = 72;
	}
	else {	
		strTemplateToUse = "class_record_60.xls";
		iRowsPerPg = 60;
	}
	
	WTE.setPath(strInstallDir, strTemplateToUse);
	
	
	for(int i =0; i < vClassList.size();) {
		//do not print if rows exceeds max row size.

		System.out.println("starting to write: "+strSubCode+"-"+strSection+".xls");
		WTE.WriteClose();
		WTE.createFile(strSubCode+"-"+strSection+".xls");
	
		WTE.writeData(strSubCode, 4,0);
		WTE.writeData(strSubName, 4,4);
		WTE.writeData(strSYTerm, 4,15);
		
		strTemp = strLecTime;
		if(strLabTime != null)
			strTemp = strTemp + "\n(LAB) "+strLabTime;
		
		WTE.writeData(strTemp, 4,21);
		WTE.writeData(strSection, 4,26);
		
		if(i > 0 || bolForcePrint){%>
		<!--<DIV style="page-break-before:always" >&nbsp;</DIV>-->
		<%bolForcePrint = true;}%>
<!--		
		  <table width="100%" border="0" cellpadding="0" cellspacing="0">
		   <tr>
		     <td width="5%" style="font-size:18px;" align="center"><img src="../../../images/logo/CIT_CEBU.gif" height="75" width="75"></td>
			  <td width="90%" style="font-size:22px;" align="center">CEBU INSTITUTE OF TECHNOLOGY - UNIVERSITY<BR>
			  <font style="font-size:16px;">CEBU CITY
			  <BR>OFFICIAL CLASS RECORD			  </font>			  </td>
			</tr>
		</table>
		<table width="100%" align="center" cellspacing="0" cellpadding="0">
			<tr align="center">
				<td width="10%" class="thinborderBOTTOM"><%=strSubCode%></td>
			    <td width="1%">&nbsp;</td>
				<td width="20%" class="thinborderBOTTOM"> <%=strSubName%></td>
				<td width="1%">&nbsp;</td>
			    <td width="15%" class="thinborderBOTTOM"><%=strSYTerm%></td>
			    <td width="1%">&nbsp;</td>
			    <td width="15%" class="thinborderBOTTOM"><%=strLecTime%><%if(strLabTime != null){%><br>(LAB) <%=strLabTime%><%}%></td>
			    <td width="1%">&nbsp;</td>
			    <td width="5%" class="thinborderBOTTOM"><%=strSection%></td>
			</tr>
			<tr align="center">
			  <td>Subject No </td>
			  <td>&nbsp;</td>
			  <td>Description of Subject </td>
			  <td>&nbsp;</td>
			  <td>Sem. & School Year </td>
			  <td>&nbsp;</td>
			  <td>Time</td>
			  <td>&nbsp;</td>
			  <td>Section</td>
			</tr>
		</table>
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
					WTE.writeData((String)vClassList.elementAt(i + 1), iRowsPrinted+10,1);
					strTemp = (String)vClassList.elementAt(i + 3) + WI.getStrValue((String)vClassList.elementAt(i + 4), "-", "","") + WI.getStrValue((String)vClassList.elementAt(i + 5), "-", "","");
					
					WTE.writeData(strTemp, iRowsPrinted+10,7);
					%>
					<tr>
						<td height="16" class="thinborder"<%=strFontSize%>><%=++iCount%>.</td>
						<td class="thinborder"<%=strFontSize%>><%=vClassList.elementAt(i + 1)%></td>
						<td class="thinborder"<%=strFontSize%>><%=vClassList.elementAt(i + 3)%><%=WI.getStrValue((String)vClassList.elementAt(i + 4), "-", "","")%><%=WI.getStrValue((String)vClassList.elementAt(i + 5), "-", "","")%></td>
					    <td class="thinborder"<%=strFontSize%>>&nbsp;</td>
					    <td class="thinborder"<%=strFontSize%>>&nbsp;</td>
					    <td class="thinborder"<%=strFontSize%>>&nbsp;</td>
					    <td class="thinborder"<%=strFontSize%>>&nbsp;</td>
					    <td class="thinborder"<%=strFontSize%>>&nbsp;</td>
					    <td class="thinborder"<%=strFontSize%>>&nbsp;</td>
					    <td class="thinborder"<%=strFontSize%>>&nbsp;</td>
					    <td class="thinborder"<%=strFontSize%>>&nbsp;</td>
					    <td class="thinborder"<%=strFontSize%>>&nbsp;</td>
					    <td class="thinborder"<%=strFontSize%>>&nbsp;</td>
					    <td class="thinborder"<%=strFontSize%>>&nbsp;</td>
					    <td class="thinborder"<%=strFontSize%>>&nbsp;</td>
					    <td class="thinborder"<%=strFontSize%>>&nbsp;</td>
					    <td class="thinborder"<%=strFontSize%>>&nbsp;</td>
					    <td class="thinborder"<%=strFontSize%>>&nbsp;</td>
					    <td class="thinborder"<%=strFontSize%>>&nbsp;</td>
					    <td class="thinborder"<%=strFontSize%>>&nbsp;</td>
					    <td class="thinborder"<%=strFontSize%>>&nbsp;</td>
					</tr>
				<%}
				boolean bolNothingFollows = true;
				if(iCount < iRowsPerPg) {
					//WTE.writeData("***** NOTHING FOLLOWS ****", iRowsPrinted+10,1);
					strTemp = "NOTE: Students whose names do not appear in the list must not be accepted. Refer these students to ETO.";
					WTE.writeData(strTemp, iRowsPrinted+10,1);
					WTE.mergeCell(strTemp,1, iRowsPrinted+10, 1, 24);// 1 = , there is one more merged row in same row.. merge from column 1 to 24 columns. 
				}
				
				while(iCount < 60) {%>
					<tr>
						<td height="16" class="thinborder"><%=++iCount%>.</td>
						<td class="thinborder"><%if(bolNothingFollows){%>***** NOTHING FOLLOWS ****<%bolNothingFollows = false;}%>&nbsp;</td>
						<td class="thinborder">&nbsp;</td>
					    <td class="thinborder">&nbsp;</td>
					    <td class="thinborder">&nbsp;</td>
					    <td class="thinborder">&nbsp;</td>
					    <td class="thinborder">&nbsp;</td>
					    <td class="thinborder">&nbsp;</td>
					    <td class="thinborder">&nbsp;</td>
					    <td class="thinborder">&nbsp;</td>
					    <td class="thinborder">&nbsp;</td>
					    <td class="thinborder">&nbsp;</td>
					    <td class="thinborder">&nbsp;</td>
					    <td class="thinborder">&nbsp;</td>
					    <td class="thinborder">&nbsp;</td>
					    <td class="thinborder">&nbsp;</td>
					    <td class="thinborder">&nbsp;</td>
					    <td class="thinborder">&nbsp;</td>
					    <td class="thinborder">&nbsp;</td>
					    <td class="thinborder">&nbsp;</td>
					    <td class="thinborder">&nbsp;</td>
					</tr>
				<%}%>
			</table>
			
			
		
	<%}//outer for loop.
	strTemp = null;
	iIndexOf = vDeanInfo.indexOf(strSubSecIndex);
	if(iIndexOf > -1)
		strTemp = (String)vDeanInfo.elementAt(iIndexOf + 1);
		
	if(iRowsPerPg == 60)
		WTE.writeData(WI.getStrValue(strLecFac, ""), 71,1);
	else if(iRowsPerPg == 72)
		WTE.writeData(WI.getStrValue(strLecFac, ""), 83,1);
	else 
		WTE.writeData(WI.getStrValue(strLecFac, ""), 311,1);

	//Write here dean and faculty..
	strTemp = WI.getStrValue(strTemp, "");
	if(iRowsPerPg == 60)
		WTE.writeData(strTemp, 71,11);
	else if(iRowsPerPg == 72)
		WTE.writeData(strTemp, 83,11);
	else
		WTE.writeData(strTemp, 311,11);
	
	%>
	<br>
	
	<table width="80%" align="center">
	<tr align="center">
		<td width="40%" class="thinborderBOTTOM" valign="bottom" height="35"><%=WI.getStrValue(strLecFac,"&nbsp;")%></td>
		<td width="40%" class="thinborderBOTTOM" valign="bottom"><%=WI.getStrValue(strTemp,"&nbsp;")%></td>
		<td width="20%">&nbsp;</td>
	</tr>
	<tr align="center">
	  <td>Instructor</td>
	  <td>Dean</td>
	  <td>&nbsp;</td>
	  </tr>
	</table>
-->		
	
    <%}//while(vSubSecRef.size() > 0) 
WTE.WriteClose();
%>
To Get the files go to E:/ApacheTomcat5.0.28/schoolautomate/download/

</body>
</html>
<%
dbOP.cleanUP();
%>