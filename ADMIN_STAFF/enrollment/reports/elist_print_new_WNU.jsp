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
	String strCollegeName = null;
	String strCollegeIndex = null;
	String strCollegeCode = null;
	String strMajorCode = null;
	

	String strSchCode = null;//for UI , do not show remarks.
	//for CLDH, show total enrolled unit instead of remark.


	String[] astrConvertSem = {"Summer","1st Semester","2nd Semester","3rd Semester","4th Semester","5th Semester"};
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
Vector vEnrlInfo = new Vector();
boolean bolSeparateName = false;
int iNoOfSubPerRow = 6;
boolean bolShowPageBreak = false;

strSchCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchCode == null)
	strSchCode = "";

boolean bolIsVMA = strSchCode.startsWith("VMA");
	

//strSchCode = "VMUF";
boolean bolShowID = false; 

boolean bolIsForm19 = false; Vector avAddlInfo = null;


int iTotalStud = 0;
Vector vRetResult = null; Vector vCollegeInfo = new Vector();
strTemp = "select count(*) from stud_curriculum_hist where sy_from = "+request.getParameter("sy_from")+
			  " and semester = "+request.getParameter("semester")+
			  " and is_valid = 1 and exists (select * from enrl_final_cur_list where "+
			  "user_index = stud_curriculum_hist.user_index and is_valid = 1 and is_temp_stud = 0 and "+
			  "semester = current_semester and sy_from = stud_curriculum_hist.sy_from) ";
if(bolIsVMA)
	strTemp = strTemp + " and course_index = "+WI.fillTextValue("course_index")+" and year_level = "+WI.fillTextValue("year_level");
	
strTemp = dbOP.getResultOfAQuery(strTemp, 0);
if(strTemp == null)
	strErrMsg = "No student list found.";
else {
	iTotalStud = Integer.parseInt(strTemp);
	strTemp = "select c_Name, c_index from college where is_del = 0 order by c_name";
	java.sql.ResultSet rs = dbOP.executeQuery(strTemp);
	while(rs.next()){
		vCollegeInfo.addElement(rs.getString(1));//[0] c_name
		vCollegeInfo.addElement(rs.getString(2));//[1] c_index
		if(bolIsVMA)
			break;
	}
	rs.close();
}
	
//dbOP.cleanUP();
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

int iDefNoOfRowPerPg = 0;
if(request.getParameter("stud_per_pg") == null)
	iDefNoOfRowPerPg = 36;
else
	iDefNoOfRowPerPg = Integer.parseInt(request.getParameter("stud_per_pg"));

int iNoOfRowPerPg = iDefNoOfRowPerPg;
//if(strSchCode.startsWith("UI") || strSchCode.startsWith("LNU") )
//	iNoOfRowPerPg = 20;

int iStudCount = 1;
int iTemp = iTotalStud;//total no of rows.
//iTemp is not correct -- i have to run a for loop to find number of rows.

int iTotalNoOfPage = iTemp / iNoOfRowPerPg;
if(iTemp%iNoOfRowPerPg > 0) ++iTotalNoOfPage;

/** not possible here anymore.. 
/////////////////// compute here number of pages. //////////////////////
int iTempPageNo = 1;
for(int i=4; i<vRetResult.size();){
	iNoOfRowPerPg = iDefNoOfRowPerPg;
	for(; i<vRetResult.size();++i){// this is for page wise display.
		vEnrlInfo = (Vector)vRetResult.elementAt(i);
		if(iNoOfRowPerPg <= 0) {
			++iTempPageNo;
			break;
		}
		if(iNoOfSubPerRow == 20) {
			--iNoOfRowPerPg;
			continue; 
		}
		for(int k=4; k<vEnrlInfo.size();){
			k += 2; // only 6 rows or 4 rows(for AUF)
		}
		iNoOfRowPerPg -= 2;
	}
}

if(iTempPageNo != iTotalNoOfPage)
	iTotalNoOfPage = iTempPageNo;

/////////////////// end of computation for total # of pages. ///////////
**/

int iPageCount = 1;
String strUserIndex = null;
String strPgCountDisp = null;
int iTotCol = iNoOfSubPerRow * 2;// = 12
int iTotColPlus = iTotCol + 4;///= 16,  4 = number of elements before subject+unit info =
double dUnitEnrolled = 0d; String strUnit = null; String strGrade = null;
String strClass = null;
int k = 0 ; // index for inner loop (student loop) 
String strSubjectsLoad = null;
int iStudNumber = 1;

int iSubLen = 0;

String strSchoolInfo = null;
if(strSchCode.startsWith("WNU")) {
	strSchoolInfo = "West Negros University</font><br> "+
					"(Formerly West Negros College)<br>"+
					"Bacolod City, Philippines<br><br>";
}
else if(strSchCode.startsWith("VMA")){
	strSchoolInfo = "VMA GLOBAL COLLEGE</font><br> "+
					"Asian Mari-Tech Development Corporation<br>"+
					"Sum-ag, Bacolod City<br><br>Office of the Registrar<br><br>";
}

String strCourseName = null;
if(bolIsVMA) {
	strCourseName = "select course_name from course_offered where course_index = "+WI.fillTextValue("course_index");
	strCourseName = dbOP.getResultOfAQuery(strCourseName, 0);
	if(WI.fillTextValue("year_level").length() > 0) {
		int iYrLevel = Integer.parseInt(WI.fillTextValue("year_level"));
		if(iYrLevel == 1)
			strCourseName = strCourseName +" - 1st Year";
		if(iYrLevel == 2)
			strCourseName = strCourseName +" - 2nd Year";
		if(iYrLevel == 3)
			strCourseName = strCourseName +" - 3rd Year";
		if(iYrLevel == 4)
			strCourseName = strCourseName +" - 4th Year";
		if(iYrLevel == 5)
			strCourseName = strCourseName +" - 5th Year";
		if(iYrLevel == 6)
			strCourseName = strCourseName +" - 6th Year";
	}
	
}


while(vCollegeInfo.size() > 0) {
strCollegeName = (String)vCollegeInfo.remove(0);
request.setAttribute("college_index",vCollegeInfo.remove(0));
if(strCollegeName.startsWith("Integrated"))//this is highschool. 
	continue;
vRetResult = enrlReport.getEnrollmentListWNU(dbOP,request,iNoOfSubPerRow,bolSeparateName,true);
if(vRetResult == null) {
	//System.out.println(enrlReport.getErrMsg());
	//System.out.println(strCollegeName);
	continue;
}

for(int i=4; i<vRetResult.size();){

	//iNoOfRowPerPg = iDefNoOfRowPerPg;
	%>
	
	<table width="1136" border="0" cellspacing="0" cellpadding="0">
	  <tr>
		<td colspan="2">
<%if(bolShowPageBreak || iPageCount == 1 ) {%>
		<div align="center">
			<font style="font-size:12px; font-weight:bold"> 
				<%=strSchoolInfo%>
			<strong> CHED ENROLMENT LIST</strong><br>			  
	<%
	strTemp = request.getParameter("semester");
	if(WI.fillTextValue("show_2nd_sem").length() > 0) 
		strTemp = "2";
	%>		 School Year: 
		<%=request.getParameter("sy_from")%> - <%=Integer.parseInt((String)request.getParameter("sy_from")) + 1%>/
		<%=astrConvertSem[Integer.parseInt(strTemp)]%></div>
<%}else{--iNoOfRowPerPg;%><br><%}%>
	<strong>
	<%if(bolIsVMA){%>
		<%=strCourseName.toUpperCase()%>
	<%}else{%>
		<%=WI.getStrValue(strCollegeName, "Department : ", "","")%></strong><%strCollegeName = null;%>
	<%}%>
	</td>
	  </tr>
	</table>
	<table width="1200" border="0" cellpadding="0" cellspacing="0" class="jumboborder">
	  <tr>
		<td class="jumboborderRIGHTBottom">No.</td>
		<td colspan="2" class="jumboborderRIGHTBottom">&nbsp;NAME OF STUDENT</td>
		<td width="75" class="jumboborderRIGHTBottom">TOTAL LOAD<br>
		(in Units) </td>
		<td width="122" class="jumboborderRIGHTBottom">ID NO. </td>
		<td width="68" class="jumboborderRIGHTBottom">COURSE</td>
		<td width="50" class="jumboborderRIGHTBottom">YEAR LEVEL </td>
		<td width="56" class="jumboborderRIGHTBottom">MAJOR</td>
		<td width="50" class="jumboborderBottom">GENDER</td>
	  </tr>
	  <%
	
	//Vector -> [0]=id [1] =name,[2]=gender,[3]=course regularity -- one time. =>repeat =>[4]=sub_code,[5]=unit
	
	
	
	for(; i<vRetResult.size();++i){// this is for page wise display.
		vEnrlInfo = (Vector)vRetResult.elementAt(i);
		
		if(iNoOfRowPerPg <= 0) {
			bolShowPageBreak = true;
			iNoOfRowPerPg = iDefNoOfRowPerPg;
			break;
		}
		bolShowPageBreak = false;
		dUnitEnrolled = 0d;
		strSubjectsLoad = null;
		
		for (k = 7 ; k < vEnrlInfo.size() ; k+=2){
			dUnitEnrolled += Double.parseDouble((String)vEnrlInfo.elementAt(k+1));
			strTemp = (String) vEnrlInfo.elementAt(k) +"/" + (String) vEnrlInfo.elementAt(k +1);
			if(bolIsVMA)
				strTemp = (String) vEnrlInfo.elementAt(k) +"(" + (String) vEnrlInfo.elementAt(k +1)+")";
			
	
			if (strSubjectsLoad == null) {
				strSubjectsLoad = strTemp;
				iSubLen = strTemp.length();
			}
			else {
				strSubjectsLoad += "&nbsp; " +strTemp;
				iSubLen += strTemp.length() + 2;
			}
		}	
		if(iSubLen > 105)
			iNoOfRowPerPg -=3;
		else	
			iNoOfRowPerPg -=2;
		%>
	  <tr>
		<td height="15" class="<%=strClass%>">&nbsp;<%=iStudNumber++%></td>
		<td colspan="2" class="<%=strClass%>">&nbsp;<%=(String)vEnrlInfo.elementAt(1)%></td>
		<td rowspan="2" class="<%=strClass%>"> &nbsp;<%=CommonUtil.formatFloat(dUnitEnrolled,false)%></td>
		<td rowspan="2" class="<%=strClass%>"> &nbsp;<%=(String)vEnrlInfo.elementAt(0)%></td>
		<td rowspan="2" class="<%=strClass%>">&nbsp;<%=(String)vEnrlInfo.elementAt(4)%> </td>
		<td rowspan="2" class="<%=strClass%>">&nbsp;<%=WI.getStrValue((String)vEnrlInfo.elementAt(6))%> </td>
		<td rowspan="2" class="<%=strClass%>">&nbsp;<%=WI.getStrValue((String)vEnrlInfo.elementAt(5))%> </td>
		<td rowspan="2" class="<%=strClass%>"> &nbsp;<%=(String)vEnrlInfo.elementAt(2)%></td>
	  </tr>
	  <tr>
		<td width="44" valign="top" class="<%=strClass%>" >&nbsp;</td>
		<td width="20" height="15" valign="top" class="<%=strClass%>" >&nbsp;</td>
		<td width="695" valign="top" class="<%=strClass%>" ><%=strSubjectsLoad%></td>
	  </tr>
	  <%
	
	 }//end of print per page.
	 //if(vCollegeInfo.size()> 0 && !bolShowPageBreak)
	 //	bolShowPageBreak = true;%>
	</table>
<%
if(iNoOfRowPerPg < 3) {
	bolShowPageBreak = true;
	iNoOfRowPerPg = iDefNoOfRowPerPg;
}
if(vCollegeInfo.size() > 0) {
	if( ((String)vCollegeInfo.elementAt(0)).startsWith("Integrated")) {//this is highschool. 
		vCollegeInfo.remove(0);vCollegeInfo.remove(0);
	}
}
if(bolShowPageBreak || vCollegeInfo.size() == 0){%>
	<table width="1136" border="0" cellspacing="0" cellpadding="0">
	  <tr>
		<td width="1136" align="center">Page count : <%=Integer.toString(iPageCount++)%> of <input type="text" name="_<%=iPageCount%>" class="textbox_noborder" style="font-size:11px;font-weight:normal;" size="5"></td>
	  </tr>
	
	</table>
	<!-- introduce page break here -->
<%}if(bolShowPageBreak){%>
	<DIV style="page-break-after:always">&nbsp;</DIV>
	<%}//break only if it is not last page.

}//end of printing. - outer for loop.

}//end of while(vCollegeInfo.size() > 0)

--iPageCount;
dbOP.cleanUP();
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