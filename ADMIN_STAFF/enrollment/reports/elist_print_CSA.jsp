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
/**
<%if(WI.fillTextValue("show_border").compareTo("1") ==0){%>
**/
    TABLE.thinborder {
    border-top: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

    TD.thinborder {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
    TD.thinborderSP {
    border-left: solid 1px #000000;
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
/**
<%}else{%>
**/
    TD.thinborderSP {
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 9px;
    }
/**
<%}%>
**/
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

<body topmargin="0" bottommargin="0" onLoad="CallOnLoad();window.print();" bgcolor="#DDDDDD">
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
	String strCollegeName = null;
	String strCollegeIndex = null;

	String[] astrConvertSem = {"SUMMER","FIRST SEMESTER","SECOND SEMESTER","THIRD SEMESTER"};
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
int iRowsPerPage = 34;
int iSubjectPerRow = 7;
Vector vRetResult = null;
    Vector vUserIndex     = new Vector();
    Vector vStudBasicInfo = new Vector();
    Vector vEnrlInfo      = new Vector();//[0] user_index, [1] = total units enrolled, [2] = total subjects enrolled, [3] sub_code, sub_name, units - Vector.
	Vector vSubInfo       = new Vector();

vRetResult = enrlReport.getEnrollmentListCSA(dbOP, request);
if(vRetResult == null || ((Vector)vRetResult.elementAt(0)) == null)
	strErrMsg = enrlReport.getErrMsg();
else {
	vUserIndex     = (Vector)vRetResult.remove(0);
    vStudBasicInfo = (Vector)vRetResult.remove(0);
    vEnrlInfo      = (Vector)vRetResult.remove(0);
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

while(vUserIndex.size() > 0) {
iRowsPrinted =0;
if(iPageNo > 0) {%>
	<DIV style="page-break-before:always" >&nbsp;</DIV>
<%}
if(bolIsCSA){%>
	<table width="100%" cellpadding="0" cellspacing="0">
		<tr>
			<td width="33%">COLEGIO SAN AGUSTIN-BACOLOD</td>
			<td width="33%" align="center">ENROLLMENT LIST</td>
			<td width="33%" align="right">PAGE NO.: <%=++iPageNo%></td>
		</tr>
		<tr>
			<td width="33%">BACOLOD CITY</td>
			<td width="33%" align="center"><%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))]%> <%=WI.fillTextValue("sy_from")%> - <%=WI.fillTextValue("sy_to")%></td>
			<td width="33%">&nbsp;</td>
		</tr>
	</table>
<%}%>
	<table width="100%" cellpadding="1" cellspacing="1">
		<tr>
			<td>NO</td>
			<td width="10%">STUD NO</td>
			<td width="15%">NAME</td>
			<td>SEX</td>
			<td>COURSE-MAJOR</td>
			<td>YR</td>
			<td>TOTAL UNITS</td>
			<td width="8%">SUBJECT</td>
			<td>UN</td>
			<td width="8%">SUBJECT</td>
			<td>UN</td>
			<td width="8%">SUBJECT</td>
			<td>UN</td>
			<td width="8%">SUBJECT</td>
			<td>UN</td>
			<td width="8%">SUBJECT</td>
			<td>UN</td>
			<td width="8%">SUBJECT</td>
			<td>UN</td>
			<td width="8%">SUBJECT</td>
			<td>UN</td>
			<td width="8%">SUBJECT</td>
			<td>UN</td>
		</tr>
		<%while(vStudBasicInfo.size() > 0){		
		%>
			<tr>
			  <td><%=++iStudCount%>.</td>
			  <td><%=vStudBasicInfo.remove(0)%></td><!-- ID -->
			  <td><%=vStudBasicInfo.remove(2)%>, <%=vStudBasicInfo.remove(0)%> <%=WI.getStrValue((String)vStudBasicInfo.remove(0), "(", ")", "")%></td><!--name-->
			  <td><%=vStudBasicInfo.remove(0)%></td><!-- gender -->
			  <td><%vStudBasicInfo.remove(1);vStudBasicInfo.remove(1);%><%=vStudBasicInfo.remove(1)%></td><!-- course-major-->
			  <td><%=vStudBasicInfo.remove(0)%></td><!-- year -->
			  <%//System.out.println("User Index : "+vUserIndex.elementAt(0));
			  iIndexOf = vEnrlInfo.indexOf((String)vUserIndex.remove(0));
			  vEnrlInfo.remove(iIndexOf);//remove user_index
			  vEnrlInfo.remove(iIndexOf + 1);//number of subject..
			  vSubInfo = (Vector)vEnrlInfo.remove(iIndexOf + 1);
			  
			  %>
			  <td><%=vEnrlInfo.remove(iIndexOf)%></td>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td>
		  </tr>
		<!-- now, print if subject goes to 2nd or 3rd line -->
		<%while(vSubInfo.size() > 0){		
		%>
			<tr>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td>&nbsp;</td>
			  <td></td>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td><%enrlReport.getNextElement(vSubInfo);%>
			  <td><%=enrlReport.getNextElement(vSubInfo)%></td>
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
