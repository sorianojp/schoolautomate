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
	font-size:<%=WI.fillTextValue("font_size")%>px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size:<%=WI.fillTextValue("font_size")%>px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size:<%=WI.fillTextValue("font_size")%>px;
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
	font-size: <%=WI.fillTextValue("font_size")%>px;
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
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

    TD.jumboborderRIGHT {
    border-right: solid 1px #AAAAAA;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

    TD.jumboborderTOP {
    border-top: solid 2px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

    TD.jumboborderTOPex {
    /**border-top: solid 1px #000000;**/
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
    TD.jumboborderTOPONLY {
    border-top: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
	
	TD.thinborderTOPBOTTOM {
    border-top: solid 1px #000000;
	border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
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
int iRowsPerPage = Integer.parseInt(WI.getStrValue(WI.fillTextValue("stud_per_pg"),"18"));


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
<%}%>


<table width=100% border="0" cellspacing="0" cellpadding="0">
	<tr><td align="center">
		<%=SchoolInformation.getSchoolName(dbOP,true,false)%><br>
		<%=WI.getStrValue(SchoolInformation.getAddressLine1(dbOP,true,false),"&nbsp;")%><br>
		ENROLLMENT LISTING
	</td></tr>
	<tr><td height="25">&nbsp;</td></tr>
</table>
<table width=100% border="0" cellspacing="0" cellpadding="0">
	<tr>
		<td width="20%" height="20">Institutional Identifier : </td>
		<td width="80%">&nbsp;</td>		
	</tr>
	<tr>
		<td height="20">Semester :</td>
		<%
		strTemp = astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))] + " " +request.getParameter("sy_from")+"-"+request.getParameter("sy_to")+
			" [" +WI.fillTextValue("semester")+request.getParameter("sy_from")+"]";
		%>
		<td><%=strTemp%></td>
	</tr>
	
	
	<tr>
		<td height="20">College :</td>
		<%
		strTemp = "";
		if(WI.fillTextValue("course_index").length() > 0){
			strTemp = "select c_name from college join course_offered on (course_offered.c_index = college.c_index) where course_index = "+WI.fillTextValue("course_index");
			strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		}
		%>
		<td><%=strTemp%></td>
	</tr>
	<tr>
		<td height="20">School Year :</td>
		<td><%=request.getParameter("sy_from")%>-<%=request.getParameter("sy_to")%></td>
	</tr>
	
	
	
</table>


	<table width="100%" cellpadding="0" cellspacing="0">
		  <tr>
			<td width="3%" height="24" class="thinborderTOPBOTTOM" align="center">No.</td>
			<td width="15%" class="thinborderTOPBOTTOM">Student No</td>
			<td colspan="3" class="thinborderTOPBOTTOM">Name</td>
			<td width="3%" class="thinborderTOPBOTTOM">Sex</td>
			<td width="2%" class="thinborderTOPBOTTOM">Year</td>
			<td width="8%" class="thinborderTOPBOTTOM">Course</td>
			<td width="40%" class="thinborderTOPBOTTOM">Subject</td>
			<td width="5%" class="thinborderTOPBOTTOM" align="center">Load</td>
		  </tr>
		<%while(vStudBasicInfo.size() > 0){		
		%>
		  
		  <tr>
			<td valign="top" height="21" class=""><%=++iStudCount%>.</td>
			<td valign="top" class=""><%=vStudBasicInfo.remove(0)%></td>	
			<%
			strTemp = WebInterface.formatName((String)vStudBasicInfo.remove(0),(String)vStudBasicInfo.remove(0),(String)vStudBasicInfo.remove(0),4);
			%>
			<td valign="top" colspan="3" class=""><%=strTemp%></td>    
			<td valign="top" class=""><%=vStudBasicInfo.remove(0)%></td>
			<td valign="top" class=""><%=WI.getStrValue(vStudBasicInfo.remove(0),"0")%></td>
			<td valign="top" class=""><%vStudBasicInfo.remove(0);vStudBasicInfo.remove(0);%><%=vStudBasicInfo.remove(0)%></td>
			<%
			
			  iIndexOf = vEnrlInfo.indexOf((String)vUserIndex.remove(0));
			  vEnrlInfo.remove(iIndexOf);//remove user_index
			  vEnrlInfo.remove(iIndexOf + 1);//number of subject..
			  vSubInfo = (Vector)vEnrlInfo.remove(iIndexOf + 1);
			  
			 
			strTemp = null;
			while(vSubInfo.size() > 0){
				if(strTemp == null)
					strTemp = enrlReport.getNextElement(vSubInfo);
				else
					strTemp += ", "+enrlReport.getNextElement(vSubInfo);
				
				enrlReport.getNextElement(vSubInfo);//sub_name
				enrlReport.getNextElement(vSubInfo);//units
			}
			%>
			<td valign="top" class=""><%=WI.getStrValue(strTemp, "&nbsp;")%></td>
			
			<td valign="top" align="center" class=""><%=vEnrlInfo.remove(iIndexOf)%></td>
		  </tr>
		<%
		if(++iRowsPrinted >=iRowsPerPage)
			break;
		}//end of showing per row%>
		<tr>
			<td colspan="8">Page <%=++iPageNo%> of <label id="total_page_count_<%=iPageNo%>"></label></td>
		</tr>
	</table>

<%
}//end of outer loop.. while(vUserIndex.size() > 0 
%>
<script>
	<%
	for(int i = 1; i <= iPageNo; ++i){
	%>
	document.getElementById('total_page_count_<%=i%>').innerHTML = <%=iPageNo%>;
	<%}%>
</script>
</body>
</html>
<%
dbOP.cleanUP();
%>
