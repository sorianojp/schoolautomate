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
<style type="text/css">
<!--
body {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
}

td {
	font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;
	font-size: <%=WI.fillTextValue("font_size")%>px;
}

th {
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


-->
</style>
</head>

<body topmargin="0" bottommargin="0" onLoad="window.print();">
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
	

//strSchCode = "VMUF";
boolean bolShowID = false; 

boolean bolIsForm19 = false; Vector avAddlInfo = null;



Vector vRetResult = enrlReport.getEnrollmentList(dbOP,request,iNoOfSubPerRow,bolSeparateName,true);//8 subjects in one row -- change it for different no of subjects per row
if(vRetResult == null || vRetResult.size() ==0)
{
	strErrMsg = enrlReport.getErrMsg();
	
	if(strErrMsg == null)
		strErrMsg = "Enrollment list not found.";
}




//I have to now check if it is called to view only male or female - applicable for UDMC. 

/*
strTemp = WI.fillTextValue("gender_x");

if(strTemp.length() > 0 && vRetResult != null && vRetResult.size() > 0) {//filter gender
	for(int i = 4; i < vRetResult.size();) {
		vEnrlInfo = (Vector)vRetResult.elementAt(i);
		//System.out.println(vEnrlInfo.elementAt(2));
		if(!strTemp.equals(vEnrlInfo.elementAt(2)))
			vRetResult.removeElementAt(i);
		else	
			++i;
	}
}
*/
//System.out.println(vRetResult.size());

	

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
	iDefNoOfRowPerPg = 18;
else
	iDefNoOfRowPerPg = Integer.parseInt(request.getParameter("stud_per_pg"));

int iNoOfRowPerPg = iDefNoOfRowPerPg;
//if(strSchCode.startsWith("UI") || strSchCode.startsWith("LNU") )
//	iNoOfRowPerPg = 20;

int iStudCount = 1;
int iTemp = Integer.parseInt((String)vRetResult.elementAt(3));//total no of rows.
//iTemp is not correct -- i have to run a for loop to find number of rows.

int iTotalNoOfPage = iTemp / iNoOfRowPerPg;
if(iTemp%iNoOfRowPerPg > 0) ++iTotalNoOfPage;

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

int iPageCount = 1;
String strUserIndex = null;
String strPgCountDisp = null;

double dUnitEnrolled = 0d; String strUnit = null; String strGrade = null;
int iTotCol = iNoOfSubPerRow * 2;// = 12
int iTotColPlus = iTotCol + 4;///= 16,  4 = number of elements before subject+unit info =
String strClass = null;
int k = 0 ; // index for inner loop (student loop) 
String strSubjectsLoad = null;
int iStudNumber = 1;

for(int i=4; i<vRetResult.size();){

iNoOfRowPerPg = iDefNoOfRowPerPg;

strPgCountDisp = "Page count : "+Integer.toString(iPageCount++) +" of "+Integer.toString(iTotalNoOfPage);

%>

<table width="1136" border="0" cellspacing="0" cellpadding="0">
  <tr>
    <td colspan="2"><div align="center">
        <p><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <!-- Martin P. Posadas Avenue, San Carlos City -->
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>,<%=SchoolInformation.getAddressLine2(dbOP,false,false)%>
          <!-- Pangasinan 2420 Philippines -->
          <br>
          <!-- Tel Nos. (075) 532-2380; (075) 955-5054 FAX No. (075) 955-5477 -->
          <%=WI.getStrValue(SchoolInformation.getAddressLine3(dbOP,false,false),"","<br>","")%>
          <br>
          <strong> ENROLMENT LIST</strong><br>
          <strong>
<%
strTemp = request.getParameter("semester");
if(WI.fillTextValue("show_2nd_sem").length() > 0) 
	strTemp = "2";
%>		  <%=astrConvertSem[Integer.parseInt(strTemp)]%></strong>, Academic Year <strong><%=request.getParameter("sy_from")%> - <%=request.getParameter("sy_to")%></strong> </div>
<br /><br />
</td>
  </tr>
</table>
<table width="1165" border="0" cellpadding="0" cellspacing="0" class="jumboborder">
  <tr>
    <td class="jumboborderRIGHTBottom">No.</td>
    <td colspan="2" class="jumboborderRIGHTBottom">&nbsp;NAME OF STUDENT</td>
    <td width="75" class="jumboborderRIGHTBottom">TOTAL LOAD<br>
    (No. of Units) </td>
    <td width="122" class="jumboborderRIGHTBottom">ID NO. </td>
    <td width="68" class="jumboborderRIGHTBottom">COURSE</td>
    <td width="50" class="jumboborderRIGHTBottom">YEAR LEVEL </td>
    <td width="56" class="jumboborderRIGHTBottom">MAJOR</td>
    <td width="76" class="jumboborderBottom">GENDER</td>
  </tr>
  <%

//Vector -> [0]=id [1] =name,[2]=gender,[3]=course regularity -- one time. =>repeat =>[4]=sub_code,[5]=unit



for(; i<vRetResult.size();++i){// this is for page wise display.
	vEnrlInfo = (Vector)vRetResult.elementAt(i);
	
	if(iNoOfRowPerPg <= 0) {
		bolShowPageBreak = true;
		break;
	}
	bolShowPageBreak = false;
	dUnitEnrolled = 0d;
	strSubjectsLoad = null;
	
	for (k = 7 ; k < vEnrlInfo.size() ; k+=2){
		dUnitEnrolled += Double.parseDouble((String)vEnrlInfo.elementAt(k+1));

		if (strSubjectsLoad == null) 
			strSubjectsLoad = (String) vEnrlInfo.elementAt(k) +"/" + (String) vEnrlInfo.elementAt(k +1);
		else
			strSubjectsLoad += "&nbsp; " +(String) vEnrlInfo.elementAt(k)  +"/" +(String) vEnrlInfo.elementAt(k +1);
			
		
	}	
	iNoOfRowPerPg -=2;
	%>
  <tr>
    <td height="18" class="<%=strClass%>">&nbsp;<%=iStudNumber++%></td>
    <td height="18" colspan="2" class="<%=strClass%>">&nbsp;<%=(String)vEnrlInfo.elementAt(1)%></td>
    <td rowspan="2" class="<%=strClass%>"> &nbsp;<%=CommonUtil.formatFloat(dUnitEnrolled,false)%></td>
    <td rowspan="2" class="<%=strClass%>"> &nbsp;<%=(String)vEnrlInfo.elementAt(0)%></td>
    <td rowspan="2" class="<%=strClass%>">&nbsp;<%=(String)vEnrlInfo.elementAt(4)%> </td>
    <td rowspan="2" class="<%=strClass%>">&nbsp;<%=WI.getStrValue((String)vEnrlInfo.elementAt(6))%> </td>
    <td rowspan="2" class="<%=strClass%>">&nbsp;<%=WI.getStrValue((String)vEnrlInfo.elementAt(5))%> </td>
    <td rowspan="2" class="<%=strClass%>"> &nbsp;<%=(String)vEnrlInfo.elementAt(2)%></td>
  </tr>
  <tr>
    <td width="44" valign="top" class="<%=strClass%>" >&nbsp;</td>
    <td width="20" height="18" valign="top" class="<%=strClass%>" >&nbsp;</td>
    <td width="650" valign="top" class="<%=strClass%>" >&nbsp;<%=strSubjectsLoad%></td>
  </tr>
  <%

 }//end of print per page.%>
</table>
<table width="1136" border="0" cellspacing="0" cellpadding="0">
  <tr>
	<td width="1136" align="right"><%=strPgCountDisp%></td>
  </tr>

</table>
<!-- introduce page break here -->
<%if(bolShowPageBreak){%>
<DIV style="page-break-after:always">&nbsp;</DIV>
<%}//break only if it is not last page.

}//end of printing. - outer for loop.
dbOP.cleanUP();
%>

<script language="JavaScript">
alert("Total no of pages to print : <%=iTotalNoOfPage%>");
</script>

</body>
</html>
<%
dbOP.cleanUP();
%>