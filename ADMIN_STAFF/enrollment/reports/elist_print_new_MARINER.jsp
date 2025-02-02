<%if(request.getSession(false).getAttribute("userIndex") == null){%>
	<p style="font-size:14px; font-weight:bold; color:#FF0000;">You are logged out. Please login again.</p>
<%return;}%>
<%@ page language="java" import="utility.*,enrollment.ReportEnrollment,java.util.Vector, java.util.Date" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
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
	String[] astrConvertYr	= {"ALL YEAR LEVEL","1st Year","2nd Year","3rd Year","4th Year","5th Year","6th Year","7th Year"};
    String[] astrYr ={"All Year Level","First Year","Second Year","Third Year","Fourth Year","Fifth Year"," Six Year","Seventh Year"};
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
boolean bolPrintALL = false;
if(WI.fillTextValue("print_all_course").length() > 0) 
	bolPrintALL = true;

if(bolPrintALL) {
	strTemp = "select course_offered.course_index, major_index from course_offered left join major on (course_offered.course_index = major.course_index) "+
				" and major.is_del = 0 where is_valid = 1 order by course_offered.course_code, major.course_code ";
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	while(rs.next()) {
		vCourseInfo.addElement(rs.getString(1));//course_index
		vCourseInfo.addElement(rs.getString(2));//major_index
	}
	rs.close();
}	
else {
	vCourseInfo.addElement(WI.fillTextValue("course_index"));
	vCourseInfo.addElement(WI.fillTextValue("major_index"));
}
String strCourseIndex = null;
String strCourseCode= null;
String strMajorIndex  = null;
String strCourseName  = null;
String strMajorName   = null; 
int iPageCount = 1;


while(vCourseInfo.size() > 0) {
	strCourseIndex = (String)vCourseInfo.remove(0);
	strMajorIndex  = WI.getStrValue((String)vCourseInfo.remove(0), null);
	
	request.setAttribute("course_",strCourseIndex);
	request.setAttribute("major_",strMajorIndex);
	
	strCourseCode = "select course_code from course_offered where course_index = "+strCourseIndex;
	strCourseCode = dbOP.getResultOfAQuery(strCourseCode, 0);
	
	strCourseIndex = "select course_name from course_offered where course_index = "+strCourseIndex;
	strCourseIndex = dbOP.getResultOfAQuery(strCourseIndex, 0);
	
	if(strMajorIndex != null) {
		strMajorIndex = "select major_name from major where major_index = "+strMajorIndex;
		strMajorIndex = dbOP.getResultOfAQuery(strMajorIndex, 0);
	}
	
	//System.out.println(strCourseIndex);
	//System.out.println(strMajorIndex);
	
	strErrMsg = null;
	vRetResult = enrlReport.getEnrollmentListEAC(dbOP,request);
	if(vRetResult == null) 
		strErrMsg = enrlReport.getErrMsg();
	else
		iTotalStud = vRetResult.size() - 4;
	//dbOP.cleanUP();
	if(strErrMsg != null)
		continue;
	
	int iStudCount = 1;
	int iTemp = iTotalStud;//total no of rows.
	//iTemp is not correct -- i have to run a for loop to find number of rows.
	
	int iTotalNoOfPage = iTemp / iNoOfRowPerPg;
	if(iTemp%iNoOfRowPerPg > 0) ++iTotalNoOfPage;
	
	
	String strUserIndex = null;
	String strPgCountDisp = null;
	
	double dUnitEnrolled = 0d; String strUnit = null; String strGrade = null;
	String strClass = null;
	int k = 0 ; // index for inner loop (student loop) 
	String strSubjectsLoad = null;
	int iStudNumber = 1;
	
	int iSubLen = 0; double dTotalUnit = 0d;
	
	for(int i=4; i<vRetResult.size();){
		if(iPageCount > 1) {%>
				<DIV style="page-break-after:always">&nbsp;</DIV>
		<%}%>
		
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
		  <tr>
		      <td colspan="2" align="center">
			  		REPUBLIC OF THE PHILIPPINES<br>
					COMMISSION ON HIGHER EDUCATION<br>
					DARAGA, ALBAY
			  </td>
	        </tr>
			<tr><td colspan="2" height="25">&nbsp;</td></tr>
		  <tr>
			<td colspan="2">
			<div align="center">
				<font style="font-size:12px; font-weight:bold"> <%=SchoolInformation.getSchoolName(dbOP,true,false)%></font><br>
			<%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>			
		
		<%=astrConvertSem[Integer.parseInt(WI.fillTextValue("semester"))].toUpperCase()%>			  
		<%=request.getParameter("sy_from")%> - <%=Integer.parseInt((String)request.getParameter("sy_from")) + 1%>
		<br>
		<%=strCourseIndex%><%=WI.getStrValue(strMajorIndex, " - ", "", "")%>			</div>		</td>
		  </tr>
		</table>
	
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr>
				<td width="20%">YEAR LEVEL</td>
				<td width="80%"><%=astrConvertYr[Integer.parseInt(WI.getStrValue(WI.fillTextValue("year_level"),"0"))].toUpperCase()%></td>
			</tr>
			<tr>
				<td width="20%">Total Enrollees: </td>
				<td><%=vRetResult.elementAt(0)%> Female(<%=vRetResult.elementAt(2)%>) : Male(<%=vRetResult.elementAt(1)%>) </td>
			</tr>
		</table>
		<table width="100%" border="0" cellpadding="0" cellspacing="0">
			<tr style="font-weight:bold" align="center">
				<td width="5%" align="left">EL.No</td>
				<td width="15%" align="left">STUDENT NO.</td>
				<td width="70%">STUDENT NAME</td>
				<td width="5%">SEX</td>
				<td width="5%">AGE</td>
			</tr>
			<tr style="font-weight:bold" align="center">
				<td class="thinborderBOTTOM">&nbsp;</td>
				<td class="thinborderBOTTOM" align="left">SUBJECT CODE</td>
				<td class="thinborderBOTTOM">SUBJECT TITLE</td>
				<td class="thinborderBOTTOM">UNITS</td>
				<td class="thinborderBOTTOM">&nbsp;</td>
			</tr>
		<%
		for(; i<vRetResult.size();++i){// this is for page wise display.
			vEnrlInfo = (Vector)vRetResult.elementAt(i);
			iTemp = (vEnrlInfo.size() - 12)/3;
			iNoOfRowPerPg = iNoOfRowPerPg - iTemp-1;//to make sure one student printed in a page.
			
			//if(iNoOfRowPerPg <= 0) {
			if(!bolShowPageBreak && iStudCount > 1 && (iStudCount - 1) %5 == 0) {
				bolShowPageBreak = true;
				iNoOfRowPerPg = iDefNoOfRowPerPg;
				break;
			}
			bolShowPageBreak = false;
		%>
			<tr style="font-weight:bold">
				<td width="5%"><%=iStudCount++%></td>
				<td width="15%"><%=vEnrlInfo.elementAt(0)%></td>
				<td width="70%"><%=vEnrlInfo.elementAt(1)%></td>
				<td width="5%" align="center"><%=vEnrlInfo.elementAt(2)%></td>
				<td width="5%" align="center"><%=WI.getStrValue(vEnrlInfo.elementAt(11))%></td>
			</tr>
			<%vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);
			vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);vEnrlInfo.remove(0);
			vEnrlInfo.remove(0);vEnrlInfo.remove(0);
			while(vEnrlInfo.size() > 0) {
			dTotalUnit += Double.parseDouble((String)vEnrlInfo.elementAt(2));
			%>
				<tr>
					<td width="5%">&nbsp;</td>
					<td width="15%"><%=vEnrlInfo.remove(0)%></td>
					<td width="70%"><%=vEnrlInfo.remove(0)%></td>
					<td width="5%" align="center"><%=vEnrlInfo.remove(0)%></td>
					<td width="5%">&nbsp;</td>
				</tr>
			<%}%>
				<tr style="font-weight:bold">
					<td width="5%">&nbsp;</td>
					<td width="15%">&nbsp;</td>
					<td width="70%" align="right">Total: &nbsp;</td>
					<td width="5%" align="center"><%=dTotalUnit%></td>
					<td width="5%">&nbsp;</td>
				</tr>
		<%dTotalUnit = 0d;}//end of for loop to display content.. %>
		</table>
		<table width="100%" border="0" cellspacing="0" cellpadding="0">
		  <tr>
			<td width="100%" align="center">Page count : <%=Integer.toString(iPageCount++)%> of <input type="text" name="_<%=iPageCount%>" class="textbox_noborder" style="font-size:11px;font-weight:normal;" size="5"></td>
		  </tr>
		</table>		
		
		
	<%}%>	
	<table width="100%" border="0" cellspacing="0" cellpadding="0">
			<tr>
				<td height="20" colspan="3">&nbsp;</td>		
			</tr>
			<tr>
				<td width="8%">&nbsp;</td>
				<td width="85%" height="20" valign="middle">
					<table width="100%" border="0" cellspacing="0" cellpadding="0">
					  <tr>
						<td>
						<div style="border-top:dashed 1px #000000; border-left:dashed 1px #000000; 
						            border-bottom:dashed 1px #000000; border-right:dashed 1px #000000;">
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td>&nbsp;</td>
							</tr>
							<tr>
								<td align="center" height="20">C E R T I F I C A T I O N</td>
							</tr>
							<tr>
								<td>&nbsp;</td>
							</tr>
						</table>
						<%     int iIndexOf = 0;
							   strErrMsg = new ConversionTable().convertAmoutToFigure(Double.parseDouble(
																  Integer.toString(vRetResult.size()-4)),"Pesos"," Centavos ");
								if(strErrMsg != null) {
										iIndexOf = strErrMsg.indexOf("Pesos");
										if(iIndexOf > -1){						
										   if(strTemp == null)
											   strTemp = strErrMsg.substring(0, iIndexOf);									  
									   }
								   }						
						%>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>		
								<td width="89%" height="20">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
								I hereby certify that the total number of 
								<u><%=astrYr[Integer.parseInt(WI.getStrValue(WI.fillTextValue("year_level"),"0"))]%></u>, 
								Male/ Female students enrolled for the degree in 
								<u><%=strCourseIndex%><%=WI.getStrValue(strMajorIndex, " - ", "", "")%> (<%=strCourseCode%>)</u> is 
								<u><%=strTemp%>
								(<%=vRetResult.size()-4%>)</u> students.</td>		
							</tr>
							<tr>
								<td colspan="3">&nbsp;</td>
							</tr>
						</table>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
								<td width="18%" height="20">&nbsp;</td>
								<td width="6%">Male</td>
								<td width="3%">=</td>
								<td width="3%"><%=vRetResult.elementAt(1)%></td>
								<td width="70%">&nbsp;</td>
							</tr>
							<tr>
								<td width="18%" height="20">&nbsp;</td>
								<td width="6%">Female</td>							
								<td width="3%">=</td>
								<td width="3%">
								<div style="border-bottom:solid 1px #000000;"><%=vRetResult.elementAt(2)%>
								</div></td>
								<td width="70%">&nbsp;</td>
							</tr>
							<tr>
								<td width="18%" height="20">&nbsp;</td>
								<td width="6%">Total</td>							
								<td width="3%">=</td>
								<td width="3%"><%=vRetResult.elementAt(0)%></td>
								<td width="70%">&nbsp;</td>
							</tr>
						</table>
						<table width="100%" border="0" cellspacing="0" cellpadding="0">
							<tr>
							 <td colspan="3" height="20">&nbsp;</td>
							  <td width="31%" align="center"><%=WI.getStrValue(CommonUtil.getNameForAMemberType(dbOP, "University Registrar",7))%></td>				  
							  
							</tr>
							<tr>
							 <td colspan="3" height="20">&nbsp;</td>
							  <td align="center">Registrar</td>				  
							  
							</tr>
						</table>
						</div>
						</td>
					  </tr>
					</table>
				</td>	
				<td width="7%">&nbsp;</td>	
			</tr>
	</table>
<%}//print all LOOOOOOOOOOOP%>



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
this.updateTotalPg();
alert("Total no of pages to print : <%=iPageCount%>");
</script>
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>