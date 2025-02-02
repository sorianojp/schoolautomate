<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector, java.util.Date" %>
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	String strSchCode = null;//for UI , do not show remarks.
	//for CLDH, show total enrolled unit instead of remark.
	strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if(strSchCode == null) {%>
	
		<p style="font-size:14px; color:#FF0000; font-weight:bold">You are already logged out. Please login again.</p>
	<%return;}


	String strOrigSchCode = strSchCode;
	boolean bolIsCSA = strSchCode.startsWith("CSA");
	boolean bolIsSPC = strSchCode.startsWith("SPC");
	
	String strFontSize = WI.fillTextValue("font_size");
	if(strFontSize.length() == 0) 
		strFontSize = "8";
		
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size:9px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size:9px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size:9px;
}
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
    }
    TD.thinborderSP {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=strFontSize%>px;
    }

    TABLE.jumboborder {
    border-top: solid 2px #000000;
    border-bottom: solid 2px #000000;
    border-left: solid 2px #000000;
    border-right: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

    TD.jumboborderRIGHT {
    border-right: solid 1px #AAAAAA;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

    TD.jumboborderTOP {
    border-top: solid 2px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }

    TD.jumboborderTOPex {
    /**border-top: solid 1px #000000;**/
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
    TD.jumboborderTOPONLY {
    border-top: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }


-->
</style>
</head>
<script>
function CallOnLoad() {
	document.all.processing.style.visibility='hidden';	
	document.bgColor = "#FFFFFF";
}

</script>

<body topmargin="0" bottommargin="0" leftmargin="0" rightmargin="0" onLoad="CallOnLoad();window.print();" bgcolor="#DDDDDD">
<!-- Printing information. -->
<div id="processing" style="position:absolute; top:0px; left:0px; width:250px; height:50px;  visibility:visible">
<table cellpadding=0 cellspacing=0 border=0 Width=100% Height=100% align=Center class="thinborderALL">
      <tr>
            <td align="center" class="v10blancong" bgcolor="#FFFFFF">
			<p style="font-size:12px; font-weight:bold; font-family:Verdana, Arial, Helvetica, sans-serif"> Processing Request. Please wait...
			<br> <font color='red'>Loading Page <label id="page_progress"></label></font></p>
			
			<img src="../../../Ajax/ajax-loader_small_black.gif"></td>
      </tr>
</table>
</div>
<%
	String strErrMsg = null;String strTemp = null;

	String[] astrConvertSem = {"SUMMER","FIRST TRIMESTER","SECOND TRIMESTER","THIRD TRIMESTER"};
	String[] astrConvertYr	= {"N/A","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-Enrollment-REPORT-Enrollment list print","elist_print.jsp");
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
//get the enrollment list here.
ReportEnrollment enrlReport = new ReportEnrollment();
int iRowsPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("stud_per_pg"),"0"));
Vector vRetResult = null;
    Vector vUserIndex     = new Vector();
    Vector vStudBasicInfo = new Vector();
    Vector vEnrlInfo      = new Vector();//[0] user_index, [1] = total units enrolled, [2] = total subjects enrolled, [3] sub_code, sub_name, units - Vector.
	Vector vSubInfo       = new Vector();
	
	Vector vGradeInfo     = new Vector();
    boolean bolShowGrade  = false;
    if(WI.fillTextValue("form_19").length() > 0)
      bolShowGrade = true;

vRetResult = enrlReport.getEnrollmentListCSA(dbOP, request);
if(vRetResult == null || ((Vector)vRetResult.elementAt(0)) == null)
	strErrMsg = enrlReport.getErrMsg();
else {
	vUserIndex     = (Vector)vRetResult.remove(0);
    vStudBasicInfo = (Vector)vRetResult.remove(0);
    vEnrlInfo      = (Vector)vRetResult.remove(0);
	
	if(bolShowGrade)
		vGradeInfo = (Vector)vRetResult.remove(0); 
	
	//System.out.println("vStudBasicInfo "+vStudBasicInfo);
}
String strCollegeName = null;

if(!bolIsSPC && WI.fillTextValue("c_index").length() > 0) {//print only RegularCollege	
	strCollegeName = "select c_name from college where c_index = "+WI.fillTextValue("c_index");
	strCollegeName = dbOP.getResultOfAQuery(strCollegeName,0);	
}

	 
//System.out.println(vStudBasicInfo);
//System.out.println(vEnrlInfo);
//System.out.println(vUserIndex);
if(strErrMsg != null){%>
<table width="100%" border="0" cellpadding="0">
<tr>
	<td>
		<font size="4"><%=strErrMsg%></font>
	</td>
</tr>
</table>
<%dbOP.cleanUP();
return;
}
int iPageNo      = 0;
int iStudCount   = 0; 
int iRowsPrinted = 0;
int iIndexOf     = 0;

String strGrade = null;
String strUnit  = null;
String strSubCode = null;
String strStudIndex = null;

while(vUserIndex.size() > 0) {
iRowsPrinted =0;
if(iPageNo > 0) {%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}%>
	<table width="100%" cellpadding="0" cellspacing="0">
		<tr><td colspan="3" align="center"><%=SchoolInformation.getSchoolName(dbOP,true,false)%><br><%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br><br></td></tr>
		<tr>
			<td width="33%">&nbsp;</td>
			<td width="33%" align="center">
			<%if(bolShowGrade){%>PROMOTIONAL REPORTS<%}else{%>ENROLLMENT LISTS<%}%>
			<BR>
			<%=WI.getStrValue(strCollegeName,"<br>","<br>","")%>
			
			<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></td>
			<td width="33%" align="right">&nbsp;</td>
		</tr>
		<tr>
		  <td colspan="2"><%if(!bolIsSPC) {%>MICHELLE C. CUESTAS –ADMISSION<%}%></td>
		  <td align="right">PAGE NO.: <%=++iPageNo%></td>
	  </tr>
	</table>
	<table width="100%" cellpadding="0" cellspacing="0" class="thinborder">
		<tr>			
			<td class="thinborder" width="30%" align="center">Name of Students</td>
			<td class="thinborder">Gender</td>
			<td class="thinborder">Course</td>			
			<td class="thinborder" align="center">Major</td>	
			<td class="thinborder" align="center">Year</td>		
			<td class="thinborder" width="5%" align="center">Subject</td>
<%if(bolShowGrade) {%>
			<td class="thinborder" width="5%" align="center">Grade</td>
<%}%>
			<td class="thinborder" align="center">Units</td>
			<td class="thinborder" width="5%" align="center">Subject</td>
<%if(bolShowGrade) {%>
			<td class="thinborder" width="5%" align="center">Grade</td>
<%}%>
			<td class="thinborder" align="center">Units</td>
			<td class="thinborder" width="5%" align="center">Subject</td>
<%if(bolShowGrade) {%>
			<td class="thinborder" width="5%" align="center">Grade</td>
<%}%>
			<td class="thinborder" align="center">Units</td>
			<td class="thinborder" width="5%" align="center">Subject</td>
<%if(bolShowGrade) {%>
			<td class="thinborder" width="5%" align="center">Grade</td>
<%}%>
			<td class="thinborder" align="center">Units</td>
			<td class="thinborder" width="5%" align="center">Subject</td>
<%if(bolShowGrade) {%>
			<td class="thinborder" width="5%" align="center">Grade</td>
<%}%>
			<td class="thinborder" align="center">Units</td>
			<td class="thinborder" width="5%" align="center">Subject</td>
<%if(bolShowGrade) {%>
			<td class="thinborder" width="5%" align="center">Grade</td>
<%}%>
			<td class="thinborder" align="center">Units</td>
			<td class="thinborder" width="5%" align="center">Subject</td>
<%if(bolShowGrade) {%>
			<td class="thinborder" width="5%" align="center">Grade</td>
<%}%>
			<td class="thinborder" align="center">Units</td>
			<td class="thinborder" width="5%" align="center">Subject</td>
<%if(bolShowGrade) {%>
			<td class="thinborder" width="5%" align="center">Grade</td>
<%}%>
			<td class="thinborder" align="center">Units</td>
			<td class="thinborder" width="5%" align="center">Subject</td>
<%if(bolShowGrade) {%>
			<td class="thinborder" width="5%" align="center">Grade</td>
<%}%>
			<td class="thinborder" align="center">Units</td>
			<td class="thinborder" width="5%" align="center">Subject</td>
<%if(bolShowGrade) {%>
			<td class="thinborder" width="5%" align="center">Grade</td>
<%}%>
			<td class="thinborder" align="center">Units</td>
			<td class="thinborder" width="5%" align="center">Subject</td>
<%if(bolShowGrade) {%>
			<td class="thinborder" width="5%" align="center">Grade</td>
<%}%>
			<td class="thinborder" align="center">Units</td>
			<td class="thinborder" width="5%" align="center">Subject</td>
<%if(bolShowGrade) {%>
			<td class="thinborder" width="5%" align="center">Grade</td>
<%}%>
			<td class="thinborder" align="center">Units</td>
			<td class="thinborder" width="5%" align="center">Subject</td>
<%if(bolShowGrade) {%>
			<td class="thinborder" width="5%" align="center">Grade</td>
<%}%>
			<td class="thinborder" align="center">Units</td>
		</tr>
		<%
		//String[] astrConvertYr
		String[] astrConvertYear = {"&nbsp;","I","II","III","IV","V","VI","VII","VIII","IX","X","XI","XII","XIII","XIV","XV"};
		while(vStudBasicInfo.size() > 0){		
		%>
			<tr>
			  <!--<td><%//=++iStudCount%>.</td>
			  <td><%vStudBasicInfo.remove(0);%></td>--><!-- ID -->
			  <td class="thinborder" ><%=vStudBasicInfo.remove(2)%>, <%=vStudBasicInfo.remove(0)%> <%=WI.getStrValue(vStudBasicInfo.remove(0))%>			  </td><!--name-->
			  <td class="thinborder" align="center"><%=vStudBasicInfo.remove(0)%></td><!-- gender -->			 
			  <td class="thinborder"><%=WI.getStrValue((String)vStudBasicInfo.remove(1),"&nbsp;")%></td><!-- course--->	
			  <%
			  strTemp = (String)vStudBasicInfo.remove(1);
			  vStudBasicInfo.remove(1);
			  %>		  
			  <td class="thinborder"><%=WI.getStrValue(strTemp,"&nbsp;")%></td><!-- course-major-->
			  <td class="thinborder" align="center"><%=astrConvertYr[Integer.parseInt(WI.getStrValue((String)vStudBasicInfo.remove(0),"0"))]%></td><!-- year -->
			  <%//System.out.println("User Index : "+vUserIndex.elementAt(0));
			  if(vEnrlInfo.indexOf((String)vUserIndex.elementAt(0)) == -1) {
			  	System.out.println(vUserIndex.elementAt(0));
			  }
			  strStudIndex = (String)vUserIndex.elementAt(0);
			  
			  iIndexOf = vEnrlInfo.indexOf((String)vUserIndex.remove(0));
			  vEnrlInfo.remove(iIndexOf);//remove user_index
			  vEnrlInfo.remove(iIndexOf + 1);//number of subject..
			  vSubInfo = (Vector)vEnrlInfo.remove(iIndexOf + 1);
			  
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
			  %>
			  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>

<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
		  </tr>
		<!-- now, print if subject goes to 2nd or 3rd line -->
		<%while(vSubInfo.size() > 0){		
		%>
			<tr>
			  
			  <td class="thinborder" colspan="5">&nbsp;</td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
<%
			  strSubCode = enrlReport.getNextElement(vSubInfo);
			  enrlReport.getNextElement(vSubInfo);
			  strUnit = enrlReport.getNextElement(vSubInfo);
			  if(bolShowGrade) {
			  	iIndexOf = vGradeInfo.indexOf(strStudIndex+"-"+strSubCode);
				if(iIndexOf == -1) {
					strGrade = null;
					strUnit  = null;
				}
				else {
					strGrade = (String)vGradeInfo.elementAt(iIndexOf + 3);
					strUnit  = (String)vGradeInfo.elementAt(iIndexOf + 4);
					vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);vGradeInfo.remove(iIndexOf);
					vGradeInfo.remove(iIndexOf);
				}
			  }
%>		  
			  <td class="thinborder"><%=strSubCode%></td>
<%if(bolShowGrade) {%>
			  <td class="thinborder"><%=WI.getStrValue(strGrade, "&nbsp;")%></td>
<%}%>
			  <td class="thinborder" align="center"><%=WI.getStrValue(strUnit,"&nbsp;")%></td>
		  </tr>
		<%++iRowsPrinted;}%>



		<%
		if(++iRowsPrinted >=iRowsPerPage)
			break;
		}//end of showing per row%>
	</table>

<%
}//end of outer loop.. while(vUserIndex.size() > 0 
%>
</body>
</html>
<%
dbOP.cleanUP();
%>
