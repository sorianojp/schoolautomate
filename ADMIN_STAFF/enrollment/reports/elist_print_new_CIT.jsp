<%if(request.getSession(false).getAttribute("userIndex") == null){%>
	<p style="font-size:14px; font-weight:bold; color:#FF0000;">You are logged out. Please login again.</p>
<%return;}%>
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector, java.util.Date" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	if(WI.fillTextValue("form_19").length() > 0) {%>
		<jsp:forward page="./elist_print_new_CIT_form19.jsp" />
	<%}
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}

th {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 12px;
}
    TD.thinborderTOP {
    border-top: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
    TD.thinborderBOTTOM {
    border-bottom: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
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
    border-top: solid 1px #000000;
    border-bottom: solid 1px #000000;
    border-left: solid 1px #000000;
    border-right: solid 1px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

    TD.jumboborderRIGHT {
    border-right: solid 1px #AAAAAA;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }
	
	TD.jumboborderRIGHTBottom {
    border-right: solid 1px #AAAAAA;
    border-bottom: solid 1px #AAAAAA;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
    }

	TD.jumboborderBottom {
    border-bottom: solid 1px #AAAAAA;
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
	font-size: 11px;
    }
    TABLE.thinborderALL {
    border-left: solid 2px #000000;
    border-right: solid 2px #000000;
    border-top: solid 2px #000000;
    border-bottom: solid 2px #000000;
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: 11px;
    }


-->
</style>
</head>
<script language="javascript">
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
<form name="form_">
<%
	String strErrMsg = null;String strTemp = null;

	String strSchCode = null;//for UI , do not show remarks.
	//for CLDH, show total enrolled unit instead of remark.


	String[] astrConvertSem = {"Summer","First Semester","Second Semester","Third Semester","4th Semester","5th Semester"};
	String[] astrConvertYr	= {"ALL YEAR LEVEL","FIRST YEAR","SECOND YEAR","THIRD YEAR","FOURTH YEAR","FIFTH YEAR","SIXTH YEAR"};

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
Vector vEnrlInfo = new Vector();
boolean bolSeparateName = false;
int iNoOfSubPerRow = 6;
boolean bolShowPageBreak = false;

strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

int iTotalStud = 0;
Vector vRetResult = null; Vector vCourseInfo = new Vector();
int iDefNoOfRowPerPg = 0;
if(request.getParameter("stud_per_pg") == null)
	iDefNoOfRowPerPg = 36;
else
	iDefNoOfRowPerPg = Integer.parseInt(request.getParameter("stud_per_pg"));

int iNoOfRowPerPg = iDefNoOfRowPerPg;

String strCourseName  = null;
String strMajorName   = null; int iPageCount = 1;

int iYearLevel = Integer.parseInt(WI.getStrValue(WI.fillTextValue("year_level"), "0"));

	strCourseName = "select course_name from course_offered where course_index = "+WI.fillTextValue("course_index");
	strCourseName = dbOP.getResultOfAQuery(strCourseName, 0);
	
	if(WI.fillTextValue("major_index").length() > 0) {
		strMajorName = "select major_name from major where major_index = "+WI.fillTextValue("major_index");
		strMajorName = dbOP.getResultOfAQuery(strMajorName, 0);
	}
	strErrMsg = null;
	vRetResult = enrlReport.getEnrollmentListEAC(dbOP,request);
	if(vRetResult == null) 
		strErrMsg = enrlReport.getErrMsg();
	else
		iTotalStud = vRetResult.size() - 4;
if(vRetResult == null) {
	dbOP.cleanUP();
	%><%=strErrMsg%>
<%return;
}	
	int iStudCount = 1;
	int iTemp = iTotalStud;//total no of rows.
	//iTemp is not correct -- i have to run a for loop to find number of rows.
		
	String strPgCountDisp = null;
	
	String strStudName = null;
	String strIDNumber = null;
	
	
	double dTotalUnit = 0d; int iCount = 1;
	
	String strGenderPrinting = "MALE";
	boolean bolIsMaleAvailable = false;
	
	Vector vMale = new Vector();
	Vector vFemale = new Vector();
	
	//I have to first check if gender is there in vector.. 
	for(int i=4; i<vRetResult.size(); ++i) {
		vEnrlInfo = (Vector)vRetResult.elementAt(i);
		if(vEnrlInfo.elementAt(2).equals("M"))
			vMale.addElement(vEnrlInfo);
		else	
			vFemale.addElement(vEnrlInfo);
	} 
	if(vMale.size() > 0) {
		vRetResult = vMale;
		strGenderPrinting = "MALE";	
	}
	else {
		vRetResult = vFemale;
		strGenderPrinting = "FEMALE";	
	}
	
	while(vRetResult.size() > 0) {
		iNoOfRowPerPg = iDefNoOfRowPerPg;
		if(iPageCount++ > 1) {%>
				<DIV style="page-break-after:always">&nbsp;</DIV>
		<%}%>
		
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
		  <tr>
			<td colspan="2" style="font-weight:bold">
			<div align="center">
				<font style="font-size:12px; font-weight:bold"> <%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
			Cebu City<br>	
			
			OFFICE OF THE REGISTRAR <br>ENROLLMENT LIST WITH SUBJECTS <br>		
			<%=strCourseName.toUpperCase()%><%=WI.getStrValue(strMajorName, " - ", "", "").toUpperCase()%><br><br>
		
		<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))].toUpperCase()%>			  
		<%=request.getParameter("sy_from")%> - <%=Integer.parseInt((String)request.getParameter("sy_from")) + 1%><br>
		<br>
		<%if(iYearLevel > 0) {%>
			<u><%=astrConvertYr[iYearLevel]%></u>	
		<%}%><br><br>&nbsp;		  
			</div>
		</td>
		  </tr>
		</table>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr style="font-weight:bold" align="center">
			  <td width="2%">&nbsp;</td>
				<td width="40%"><u><%=strGenderPrinting%></u></td>
				<td width="2%">&nbsp;</td>
				<td colspan="8"><u>SUBJECTS</u></td>
			</tr>
			<tr style="font-weight:bold" align="center">
			  <td></td>
				<td></td>
				<td>&nbsp;</td>
				<td width="16%">&nbsp;</td>
				<td width="2%"><!--FG--></td>
				<td width="1%">&nbsp;</td>
				<td width="16%">&nbsp;</td>
				<td width="2%"><!--FG--></td>
				<td width="1%">&nbsp;</td>
				<td width="16%">&nbsp;</td>
				<td width="2%"><!--FG--></td>
			</tr>
			<%while(vRetResult.size() > 0) {
				vEnrlInfo = (Vector)vRetResult.elementAt(0);				
				//check if still can print in the page.. 
				iTemp = vEnrlInfo.size() - 12;
				//System.out.println("Before: "+iNoOfRowPerPg);
				iNoOfRowPerPg = iNoOfRowPerPg - iTemp/9;//3 subjects per row.. 
				if(iTemp%9 > 0)
					--iNoOfRowPerPg;
				if(iNoOfRowPerPg < 0)//must break so that i cna print all subject of a student in same page.
					break;
				//System.out.println("After: "+iNoOfRowPerPg);
			
				vRetResult.remove(0);
				
				dTotalUnit = 0d;
				for(int p = 12; p < vEnrlInfo.size(); p += 3)	
					dTotalUnit += Double.parseDouble((String)vEnrlInfo.elementAt(p + 2));
				
				strStudName = WebInterface.formatName((String)vEnrlInfo.elementAt(4), (String)vEnrlInfo.elementAt(5), (String)vEnrlInfo.elementAt(6), 4);
				strIDNumber = (String)vEnrlInfo.elementAt(0)+" ("+CommonUtil.formatFloat(dTotalUnit, false)+" units)";
				vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);
				vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);
				%>
					<tr>
					  <td><%=iCount++%></td>
					  <td>&nbsp;<%=strStudName%></td>
					  <td>&nbsp;</td>
					  <td><%if(vEnrlInfo.size() > 0) {%> <%=vEnrlInfo.elementAt(0)%>(<%=CommonUtil.formatFloat((String)vEnrlInfo.elementAt(2), false)%>)<%}%></td>
					  <td><%if(vEnrlInfo.size() > 0) {%> <!--__--><%vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);}%></td>
					  <td>&nbsp;</td>
					  <td><%if(vEnrlInfo.size() > 0) {%> <%=vEnrlInfo.elementAt(0)%>(<%=CommonUtil.formatFloat((String)vEnrlInfo.elementAt(2), false)%>)<%}%></td>
					  <td><%if(vEnrlInfo.size() > 0) {%> <!--__--><%vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);}%></td>
					  <td>&nbsp;</td>
					  <td><%if(vEnrlInfo.size() > 0) {%> <%=vEnrlInfo.elementAt(0)%>(<%=CommonUtil.formatFloat((String)vEnrlInfo.elementAt(2), false)%>)<%}%></td>
					  <td><%if(vEnrlInfo.size() > 0) {%> <!--__--><%vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);}%></td>
				  </tr>
					<tr>
					  <td>&nbsp;</td>
					  <td>&nbsp;<%=strIDNumber%></td>
					  <td>&nbsp;</td>
					  <td><%if(vEnrlInfo.size() > 0) {%> <%=vEnrlInfo.elementAt(0)%>(<%=CommonUtil.formatFloat((String)vEnrlInfo.elementAt(2), false)%>)<%}%></td>
					  <td><%if(vEnrlInfo.size() > 0) {%> <!--__--><%vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);}%></td>
					  <td>&nbsp;</td>
					  <td><%if(vEnrlInfo.size() > 0) {%> <%=vEnrlInfo.elementAt(0)%>(<%=CommonUtil.formatFloat((String)vEnrlInfo.elementAt(2), false)%>)<%}%></td>
					  <td><%if(vEnrlInfo.size() > 0) {%> <!--__--><%vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);}%></td>
					  <td>&nbsp;</td>
					  <td><%if(vEnrlInfo.size() > 0) {%> <%=vEnrlInfo.elementAt(0)%>(<%=CommonUtil.formatFloat((String)vEnrlInfo.elementAt(2), false)%>)<%}%></td>
					  <td><%if(vEnrlInfo.size() > 0) {%> <!--__--><%vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);}%></td>
				  </tr>
				  <%while(vEnrlInfo.size() > 0) {%>
					<tr>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
					  <td>&nbsp;</td>
					  <td><%if(vEnrlInfo.size() > 0) {%> <%=vEnrlInfo.elementAt(0)%>(<%=CommonUtil.formatFloat((String)vEnrlInfo.elementAt(2), false)%>)<%}%></td>
					  <td><%if(vEnrlInfo.size() > 0) {%> <!--__--><%vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);}%></td>
					  <td>&nbsp;</td>
					  <td><%if(vEnrlInfo.size() > 0) {%> <%=vEnrlInfo.elementAt(0)%>(<%=CommonUtil.formatFloat((String)vEnrlInfo.elementAt(2), false)%>)<%}%></td>
					  <td><%if(vEnrlInfo.size() > 0) {%> <!--__--><%vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);}%></td>
					  <td>&nbsp;</td>
					  <td><%if(vEnrlInfo.size() > 0) {%> <%=vEnrlInfo.elementAt(0)%>(<%=CommonUtil.formatFloat((String)vEnrlInfo.elementAt(2), false)%>)<%}%></td>
					  <td><%if(vEnrlInfo.size() > 0) {%> <!--__--><%vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);}%></td>
				    </tr>
				  <%}%>
				<tr>
					<td colspan="11">&nbsp;</td>
				</tr>

			<%}//end of while loop to print content.. %>
			</table>

		<%
		if(vRetResult.size() == 0 && vFemale.size() > 0 && !strGenderPrinting.equals("FEMALE")) {
			vRetResult = vFemale;
			strGenderPrinting = "FEMALE";
			iCount = 1;	
		}

		%>
			


	
<%}%>	



<%
--iPageCount;
%>

<script language="JavaScript">
function updateTotalPg() {
	var totalPg = <%=iPageCount + 1%>;
	var objLabel; var strTemp;
	for(var i = 2; i <= totalPg; ++i) {
		strTemp = i; 
		eval('objLabel=document.form_._'+i);
		if(!objLabel)
			continue;
		
		objLabel.value = "<%=iPageCount%>";
	}
}
//this.updateTotalPg();
alert("Total no of pages to print : <%=iPageCount%>");
</script>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>