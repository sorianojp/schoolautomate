<%@ page language="java" import="utility.*,java.util.Vector,hr.*"%>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Applicant's Data Card</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<style type="text/css">
TD{
	font-size:11px;
}

td.thinBorderBottom{
	border-bottom:#000000 solid 1px;
}
td.thinborder{
	border-bottom:#000000 solid 1px;
	border-left:#000000 solid 1px;
}

table.thinborder{
	border-top:#000000 solid 1px;
	border-right:#000000 solid 1px;
}

</style>
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}


</style>
</head><script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<script language="JavaScript">
function Convert() {
	var pgLoc = 
	"../../../commfile/conversion.jsp?called_fr_form=appl_profile&cm_field_name=height&lb_field_name=weight";
	
	var win=window.open(pgLoc,"PrintWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function viewInfo(){
	document.appl_profile.print_page.value="";
}


function OpenSearch() {
	var pgLoc = "./applicant_search_name.jsp?opner_info=appl_profile.appl_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}


function CancelRecord(strEmpID){
	location = "./hr_applicant_201.jsp";
}
function FocusID() {
	document.appl_profile.appl_id.focus();
}

function PrintPage(){
	document.appl_profile.print_page.value= "1";
	document.appl_profile.submit();
}	

</script>

<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strImgFileExt = null;

	if (WI.fillTextValue("print_page").equals("1")){ %>
		<jsp:forward page="./hr_applicant_201_print.jsp" />
<% return;}


//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-APPLICANTS DIRECTORY-Personal Data","hr_applicant_201.jsp");
		
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
		strErrMsg = "Error in opening DB Connection.";
		%>
		
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"> 
		  Error in opening connection </font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"HR Management","APPLICANTS DIRECTORY",request.getRemoteAddr(), 
														"hr_applicant_personal.jsp");	
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)//NOT AUTHORIZED.
{
	dbOP.cleanUP();
	response.sendRedirect("../../../commfile/unauthorized_page.jsp");
	return;
}
Vector vRetResult = null;
Vector vApplicantInfo  = null;
boolean bolNoRecord = true;
String strInfoIndex = WI.fillTextValue("info_index");

HRApplPersonalExtn hrApplPersonal = new HRApplPersonalExtn();
hr.HRApplNew hrApplNew = new hr.HRApplNew();
HRInfoLicenseETSkillTraining hrt = new HRInfoLicenseETSkillTraining();

strTemp = WI.fillTextValue("appl_id");
if(strTemp.length() > 0){
	vApplicantInfo = hrApplNew.operateOnApplication(dbOP, request,3);//view one.
	if(vApplicantInfo == null)
		strErrMsg = hrApplNew.getErrMsg();
}

boolean bolClearEntries = false;
Vector vRetEduc = null;
Vector vRetLicense  = null;
Vector vRetPrevEmp = null;
Vector vRetExams = null;
Vector vRetSkills = null;
Vector vRetTrainings = null;
Vector vRetLanguage = null;
Vector vRetReference = null;

if (vApplicantInfo != null && vApplicantInfo.size() > 0){//proceed here. 
	vRetResult = hrApplPersonal.operateOnPersonalData(dbOP,request,3);
	vRetEduc = new HRInfoEducation().operateOnEducation(dbOP,request,4);
	vRetLicense = hrt.operateOnLicense(dbOP,request,4);
	vRetPrevEmp = new HRInfoPrevEmployment().operateOnPrevEmployment(dbOP,request,4);
	vRetExams = hrt.operateOnExamTaken(dbOP,request,4);
	vRetSkills = hrt.operateOnSkills(dbOP, request,4);
	vRetTrainings = hrt.operateOnTraining(dbOP, request,4);
	vRetLanguage = new HRInfoLanguage().operateOnLanguage(dbOP, request,4);
	vRetReference = new HRApplReference().operateOnApplReference(dbOP, request, 4);
}


if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);

String[] astrCstatus={"Single", "Married","Divorced/Separated", "Widow/Widower", "Annuled", "Living Together"};
String[] astrGender ={"Male", "Female"};
%>


<body onLoad="FocusID();">
<form action="./hr_applicant_201.jsp" method="post" name="appl_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td height="25" colspan="4"><div align="center"><strong>APPLICANT INFORMATION DATA </strong></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="4">&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
    <tr > 
      <td width="17%" height="28"><div align="right"><font size="1"><strong>&nbsp;&nbsp;</strong></font>Applicant's 
          ID :&nbsp;&nbsp;</div></td>
      <td width="18%"><input type="text" name="appl_id" class="textbox"
	  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="18" value="<%=strTemp%>"> 
	  <input type="hidden" name="emp_id" value="<%=strTemp%>">
      </td>
      <td width="5%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a> 
      </td>
      <td width="60%"><input name="image" type="image" onClick="viewInfo();" src="../../../images/form_proceed.gif"></td>
    </tr>
  </table>
<%
if (vApplicantInfo != null && vApplicantInfo.size() > 0){//proceed here. %>
<table width="526" height="77" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> 
              <%strTemp = "<img src=\"../../../faculty_img/"+WI.fillTextValue("appl_id").toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\">";%>
              <%=strTemp%><br> <br> <br> <strong><%=WI.formatName((String)vApplicantInfo.elementAt(1),(String)vApplicantInfo.elementAt(2),
						 				 (String)vApplicantInfo.elementAt(3),4)%></strong><br>
              Position Applying for: <%=WI.getStrValue(vApplicantInfo.elementAt(11))%><br> 
              <%=WI.getStrValue(vApplicantInfo.elementAt(5),"<br>","")%> 
              <!-- email -->
              <%=WI.getStrValue(vApplicantInfo.elementAt(4))%> 
              <!-- contact number. -->            </td>
          </tr>
  </table>
  
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="8%" height="20" valign="bottom">Gender</td>
      <td width="22%" valign="bottom" class="thinBorderBottom">&nbsp;
	  <% if (vRetResult!= null && vRetResult.size() > 0) {%>
	  <%=astrGender[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(0),"0"))]%>
      <%}%></td>
      <td width="11%" valign="bottom"><div align="right">Nationality : </div></td>
      <td width="28%" valign="bottom" class="thinBorderBottom">&nbsp;
	  <% if (vRetResult!= null && vRetResult.size() > 0) {%> 	  
	  <%=WI.getStrValue(dbOP.mapOneToOther("HR_PRELOAD_NATIONALITY","NATIONALITY_INDEX",
								(String)vRetResult.elementAt(3), "NATIONALITY",""))%> 
	   <%}%>      </td>
      <td width="11%" valign="bottom"><div align="right">Religion : </div></td>
      <td width="20%" valign="bottom" class="thinBorderBottom">&nbsp;
	  <% if (vRetResult!= null && vRetResult.size() > 0) {%> 	  	
		<%=WI.getStrValue(dbOP.mapOneToOther("HR_PRELOAD_RELIGION","RELIGION_INDEX",
								(String)vRetResult.elementAt(4), "RELIGION", ""))%>
	 <%}%>	  </td>
    </tr>
  </table>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="12%" height="20" valign="bottom">Civil Status : </td>
      <td width="24%" valign="bottom" class="thinBorderBottom">
	  	&nbsp;
	  <% if (vRetResult!= null && vRetResult.size() > 0) { %> 		
		<%=astrCstatus[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(1),"0"))]%>		
	  <%}%>
	  </td>
      <td width="18%" valign="bottom"><div align="right">Spouse (if Married):&nbsp;</div></td>
      <td width="46%" valign="bottom" class="thinBorderBottom">&nbsp;
	  <% if (vRetResult!= null && vRetResult.size() > 0) {%> 
	  <%=WI.getStrValue(vRetResult.elementAt(2),"&nbsp;")%>
	  <%}%>
	  </td>
    </tr>
    <tr> 
      <td height="20" valign="bottom">Date of Birth : </td>
      <td valign="bottom" class="thinBorderBottom">&nbsp;
	  <% if (vRetResult!= null && vRetResult.size() > 0) {%> 	  
	  <%=WI.getStrValue((String)vRetResult.elementAt(5))%>
	  <%}%>
	  </td>
      <td valign="bottom"><div align="right">Place of Birth:&nbsp;&nbsp; </div></td>
      <td valign="bottom" class="thinBorderBottom">&nbsp;
 	  <% if (vRetResult!= null && vRetResult.size() > 0) {%> 
	  <%=WI.getStrValue(vRetResult.elementAt(6))%>
	  <%}%>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="14%" height="20" valign="bottom">Height (in cm): </td>
      <td width="8%" valign="bottom" class="thinBorderBottom">&nbsp;
	  <% if (vRetResult!= null && vRetResult.size() > 0) {%> 
	  <%=WI.getStrValue((String)vRetResult.elementAt(7),"&nbsp;")%>
	  <%}%>
	  </td>
      <td width="15%" valign="bottom"><div align="right">Weight (in lbs) : </div></td>
      <td width="13%" valign="bottom" class="thinBorderBottom">&nbsp;
	  <% if (vRetResult!= null && vRetResult.size() > 0) {%> 
	  	<%=WI.getStrValue((String)vRetResult.elementAt(8),"&nbsp;")%>
	  <%}%>
      </td>
      <td width="7%" valign="bottom"><div align="right">SSS: </div></td>
      <td width="17%" valign="bottom" class="thinBorderBottom">&nbsp;
  	  <% if (vRetResult!= null && vRetResult.size() > 0) {%> 
	  <%=WI.getStrValue(vRetResult.elementAt(9))%>
	  <%}%>
	  </td>
      <td width="8%" valign="bottom"><div align="right">TIN: </div></td>
      <td width="18%" valign="bottom" class="thinBorderBottom">&nbsp;
  	  <% if (vRetResult!= null && vRetResult.size() > 0) {%> 
	  <%=WI.getStrValue(vRetResult.elementAt(10))%>
	  <%}%>
	  </td>
    </tr>
  </table>
   <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="15%" height="25" valign="bottom"> Mailing Address : </td>
      <td width="85%" colspan="3" valign="bottom" class="thinBorderBottom">
	  &nbsp;
	  <% if (vRetResult!= null && vRetResult.size() > 0) {%> 	  
	  <%=WI.getStrValue((String)vRetResult.elementAt(16),"&nbsp;")%> 
	  <%}%>
	  </td>
    </tr>
    <tr>
      <td height="20" valign="bottom"> Home Address&nbsp;&nbsp; : </td>
      <td colspan="3" valign="bottom" class="thinBorderBottom">&nbsp;
  	  <% if (vRetResult!= null && vRetResult.size() > 0) {%> 
	  <%=WI.getStrValue((String)vRetResult.elementAt(17),"&nbsp;")%> 
	  <%}%>
	  </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="14%" height="20" valign="bottom">Father's Name : </td>
      <td width="39%" valign="bottom" class="thinBorderBottom"> &nbsp;
	  <% if (vRetResult!= null && vRetResult.size() > 0) {%> 
	  <%=WI.getStrValue(vRetResult.elementAt(11))%>
	  <%}%>
	  </td>
      <td width="13%" valign="bottom"><div align="right">Occupation : </div></td>
      <td width="34%" valign="bottom" class="thinBorderBottom">&nbsp;
 	  <% if (vRetResult!= null && vRetResult.size() > 0) {%> 
	  <%=WI.getStrValue(vRetResult.elementAt(12))%>
	  <%}%>
	  </td>
    </tr>
    <tr>
      <td height="20" valign="bottom">Mother's Name: </td>
      <td valign="bottom" class="thinBorderBottom">&nbsp;
  	  <% if (vRetResult!= null && vRetResult.size() > 0) {%> 
	  <%=WI.getStrValue(vRetResult.elementAt(13))%>
	  <%}%>
	  </td>
      <td valign="bottom"><div align="right">Occupation : </div></td>
      <td valign="bottom" class="thinBorderBottom">&nbsp;
  	  <% if (vRetResult!= null && vRetResult.size() > 0) {%> 
	  <%=WI.getStrValue(vRetResult.elementAt(14))%>
	  <%}%> 	  
	  </td>
    </tr>
  </table>
<% if (vRetEduc != null && vRetEduc.size() > 0) {%>
<br>
<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
      <td height="25" colspan="4" class="thinborder"><strong><font color="#FF0000">EDUCATIONAL RECORDS : </font></strong></td>
    </tr>
    <tr align="center">
      <td width="15%" height="25" class="thinborder"><font size="1"><strong>EDUCATION</strong></font></td>
      <td width="28%" class="thinborder"><font size="1"><strong>SCHOOL</strong></font></td>
      <td width="23%" class="thinborder"><font size="1"><strong>DEGREE</strong></font></td>
      <td width="13%" class="thinborder"><font size="1"><strong>HONORS</strong></font></td>
    </tr>
    <% 	for (int i = 0; i < vRetEduc.size(); i +=28) {%>
    <tr>
      <td class="thinborder"><font size="1"><strong><%=(String)vRetEduc.elementAt(i+21)%><br>
        </strong> Fr :<%=WI.getStrValue((String)vRetEduc.elementAt(i+8),"--") + "/"    + 
	  	 WI.getStrValue((String)vRetEduc.elementAt(i+16),"--") + "/" +
		 WI.getStrValue((String)vRetEduc.elementAt(i+17),"--")%>	
	  	<br>To : <%=WI.getStrValue((String)vRetEduc.elementAt(i+9),"--") + "/" +
	  	 WI.getStrValue((String)vRetEduc.elementAt(i+18),"--") + "/" +
		 WI.getStrValue((String)vRetEduc.elementAt(i+19),"--")%>	

</font> </td>
      <td class="thinborder"> <font size="1"><strong><%=WI.getStrValue((String)vRetEduc.elementAt(i+22),"&nbsp")%><br>
        </strong> <%=WI.getStrValue((String)vRetEduc.elementAt(i+23),"&nbsp")%>
		<br>Date Graduated : <%=WI.getStrValue((String)vRetEduc.elementAt(i+3),"--") + "/" +
	  	 WI.getStrValue((String)vRetEduc.elementAt(i+14),"--") + "/" +
		 WI.getStrValue((String)vRetEduc.elementAt(i+15),"--")%>			
		</font></td>
      <td class="thinborder">
	  <% if ( WI.getStrValue((String)vRetEduc.elementAt(i+27),"1").equals("1")) {%>
	  	(CAR)
	    <%}%>
	  <%=WI.getStrValue((String)vRetEduc.elementAt(i+2),"&nbsp")%> <%=WI.getStrValue((String)vRetEduc.elementAt(i+25),"(Major in ",")","")%> <%=WI.getStrValue((String)vRetEduc.elementAt(i+26),"(Minor in ",")","")%>
	  <%=WI.getStrValue((String)vRetEduc.elementAt(i+4),"<br> Units : <strong>","</strong>","")%>	  </td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetEduc.elementAt(i+24),"&nbsp")%></font></td>
    </tr>
    <% }// end for loop %>
  </table>
  <%} //end vRetEduc

if (vRetLicense != null && vRetLicense.size() > 0)  {  
%>
  <br>
  <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" class="thinborder">
          <tr > 
            <td height="25" colspan="5" class="thinborder"><strong> <font color="#FF0000">LICENSES :</font></strong></td>
          </tr>
          <tr align="center"> 
            <td width="22%" height="20" class="thinborder"><font size="1"><strong>LICENSE NAME</strong></font></td>
            <td width="16%" class="thinborder"><font size="1"><strong>LICENSE NO.</strong></font></td>
            <td width="11%" class="thinborder"><font size="1"><strong>ISSUED DATE</strong></font></td>
            <td width="12%" class="thinborder"><font size="1"><strong>EXPIRY DATE</strong></font></td>
            <td width="23%" class="thinborder"><strong><font size="1">REMARKS</font></strong></td>
          </tr>
          <% for (int i = 0; i < vRetLicense.size() ; i+=8) { %>
          <tr> 
            <td height="20" class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetLicense.elementAt(i+1),"&nbsp;")%></font></td>
            <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetLicense.elementAt(i+2),"&nbsp;")%></font></td>
            <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetLicense.elementAt(i+3),"&nbsp;")%></font></td>
            <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetLicense.elementAt(i+4),"&nbsp;")%></font></td>
            <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetLicense.elementAt(i+6),"&nbsp;")%></font></td>
          </tr>
          <%} // end for loop %>
  </table>  
  <%}
  
  
	if (vRetPrevEmp != null && vRetPrevEmp.size()> 0)  {  
  %>
  <br>
  <table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder" >
          <tr>
            <td height="25" colspan="3" class="thinborder"><strong><font color="#FF0000">PREVIOUS EMPLOYMENT:</font></strong></td>
          </tr>
          <tr bgcolor="#FFFFFF">
            <td width="27%" height="20" class="thinborder" > <div align="center"><font size="1"><strong>Employer
                / Address</strong></font></div></td>
            <td width="27%" class="thinborder"><div align="center"><font size="1"><strong>Position
                / Office / Department</strong></font></div></td>
            <td width="23%" class="thinborder"><div align="center"><font size="1"><strong>Inclusive
                Dates</strong></font></div></td>
          </tr>
<% for (int i = 0; i < vRetPrevEmp.size() ; i+=16) { %>
          <tr bgcolor="#FFFFFF">
            <td class="thinborder"><p><font color="#0000FF" size="1"><strong> <%=WI.getStrValue((String)vRetPrevEmp.elementAt(i),"&nbsp;")%></strong></font><font size="1"><br>
                <%=WI.getStrValue((String)vRetPrevEmp.elementAt(i+1),"&nbsp;")%><br>
                <%=WI.getStrValue((String)vRetPrevEmp.elementAt(i+2),"&nbsp;")%> </font></p></td>
            <td class="thinborder"><div align="center"><font size="1"><%=WI.getStrValue((String)vRetPrevEmp.elementAt(i+3),"&nbsp;")%><br>
                <%=WI.getStrValue((String)vRetPrevEmp.elementAt(i+4),"&nbsp;")%></font></div></td>
            <td class="thinborder"><div align="center"><font size="1"><%=WI.getStrValue((String)vRetPrevEmp.elementAt(i+6),"&nbsp;") + WI.getStrValue((String)vRetPrevEmp.elementAt(i+7)," - ","","&nbsp;")%></font></div></td>
          </tr>
	<%} // end for loop %>
  </table>  
  <%}
  
	if (vRetExams != null && vRetExams.size() > 0) { 
	
	String[] astrRatingSelect= {"%","marks","points","percentile","GPA"};	
	%>
  <br>
  <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" class="thinborder">
          <tr > 
            <td height="25" colspan="6" class="thinborder"><strong><font color="#FF0000">EXAMS RECORD:</font></strong></td>
          </tr>
          <tr align="center"> 
            <td width="20%" height="20" class="thinborder"><font size="1"><strong>TITLE OF EXAM</strong></font></td>
            <td width="9%" class="thinborder"><font size="1"><strong>DATE TAKEN</strong></font></td>
            <td width="20%" class="thinborder"><font size="1"><strong>PLACE TAKEN</strong></font></td>
            <td width="7%" class="thinborder"><font size="1"><strong>RANK</strong></font></td>
            <td width="8%" class="thinborder"><font size="1"><strong>RATING</strong></font></td>
            <td width="21%" class="thinborder"><font size="1"><strong>REMARKS</strong></font></td>
          </tr>
          <% for (int i = 0; i < vRetExams.size() ; i+=9) {
		  		strTemp = WI.getStrValue((String)vRetExams.elementAt(i+5));
				if (strTemp.length() != 0)
					strTemp += " " + astrRatingSelect[Integer.parseInt(WI.getStrValue((String)vRetExams.elementAt(i+6),"0"))];
				else strTemp = "&nbsp;";
		   %>
          <tr> 
            <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetExams.elementAt(i+1),"&nbsp;")%></font></td>
            <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetExams.elementAt(i+2),"&nbsp;")%></font></td>
            <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetExams.elementAt(i+3),"&nbsp;")%></font></td>
            <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetExams.elementAt(i+4),"&nbsp;")%></font></td>
            <td class="thinborder"><font size="1"><%=strTemp%></font></td>
            <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetExams.elementAt(i+7),"&nbsp;")%></font></td>
          </tr>
          <%} // end for loop %>
  </table>
<%} // end exams taken and passed

if (vRetSkills != null && vRetSkills.size() > 0) {
	
	String astrConvLevel[] = {"Beginner", "Intermediate","Advance","Expert"};
%>
<br>
<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" class="thinborder">
          <tr >
            <td height="25" colspan="3" class="thinborder"><strong> <font color="#FF0000">SKILLS : </font></strong></td>
          </tr>
          <tr>
            <td width="37%" height="20" class="thinborder"><div align="center"><font size="1"><strong>SKILLS
                NAME </strong></font></div></td>
            <td width="24%" class="thinborder"><div align="center"><font size="1"><strong>YEARS OF
                USE </strong></font></div></td>
            <td class="thinborder"> <div align="center"><font size="1"><strong>LEVEL</strong></font></div></td>
          </tr>
<% for (int i=0; i < vRetSkills.size() ; i +=5) { %>
          <tr>
            <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetSkills.elementAt(i+1))%></font></td>
            <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetSkills.elementAt(i+2))%></font></td>
            <td width="17%" class="thinborder"><font size="1"><%=astrConvLevel[Integer.parseInt((String)vRetSkills.elementAt(i+3))]%></font></td>
          </tr>
          <%} // end for loop %>
  </table>  
<%} // end skills
  
  if (vRetTrainings != null && vRetTrainings.size() > 0) {
	String[] astrSemimarType={"N/A","Official Time","Official Business","Representative/Proxy",""};  
%>
<br>
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
          <tr  > 
            <td height="25" colspan="4" class="thinborder"><strong><font color="#FF0000">TRAINING/SEMINAR RECORD : </font></strong></td>
          </tr>
          <tr> 
            <td width="31%" height="20" align="center" class="thinborder"><font size="1"><strong>TRAINING 
              / SEMINARS</strong></font></td>
            <td width="19%" height="20" align="center" class="thinborder"><font size="1"><strong>TYPE 
              / BUDGET</strong></font></td>
            <td width="26%" align="center" class="thinborder"><font size="1"><strong>VENUE</strong></font></td>
            <td width="11%" align="center" class="thinborder"><font size="1"><strong>DATE</strong></font></td>
          </tr>
          <% for (int i=0; i < vRetTrainings.size() ; i+=19) { %>
          <tr> 
            <td height="20" class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetTrainings.elementAt(i+1),"&nbsp;")%> <%=WI.getStrValue((String)vRetTrainings.elementAt(i+6),"<br> Conducted by : <strong>","</strong>","")%></font></td>
            <td class="thinborder"><font size="1">&nbsp;<%//=astrSemimarType[Integer.parseInt(WI.getStrValue((String)vRetTrainings.elementAt(i+14),"0"))]%> 
			<%=WI.getStrValue((String)vRetTrainings.elementAt(i+18)," - ")%>
			<%=WI.getStrValue((String)vRetTrainings.elementAt(i+13)," <br> &nbsp;Budget :","","")%></font></td>
            <td class="thinborder"><font size="1">&nbsp;<%=WI.getStrValue((String)vRetTrainings.elementAt(i+3),"&nbsp;")%></font></td>
            <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetTrainings.elementAt(i+7),"&nbsp;") + 
				WI.getStrValue((String)vRetTrainings.elementAt(i+8),"<br>&nbsp; to ", "","")%></font></td>
          </tr>
          <%} // end for loop %>
  </table>
  <%}
  
  if (vRetLanguage != null && vRetLanguage.size() > 0) {
  	String astrConvFScale[] = {"Beginner","Intermediate","Advance","Expert"};
  %>
  <br>
<table width="100%" border="0" align="center" cellpadding="1" cellspacing="0" class="thinborder">
          <tr>
            <td height="25" colspan="6" class="thinborder"><strong><font color="#FF0000">LANGUAGES :</font> </strong></td>
          </tr>
          <tr>
            <td width="27%" height="20" class="thinborder"><div align="center"><font size="1"><strong>LANGUAGE(s)</strong></font></div></td>
            <td width="5%" align="center" class="thinborder"><font size="1"><strong>SPEAK</strong></font></td>
            <td width="4%" align="center" class="thinborder"><font size="1"><strong>READ</strong></font></td>
            <td width="5%" align="center" class="thinborder"><font size="1"><strong>WRITE</strong></font></td>
            <td width="20%" align="center" class="thinborder"><div align="center"><font size="1"><strong>READ/WRITE/
                SPEAK</strong></font></div></td>
            <td width="20%" class="thinborder"> <div align="center"><font size="1"><strong>FLUENCY
                SCALE</strong></font></div></td>
          </tr>
          <%
		  String strTemp1 = null;
		  String strTemp2 = null;
		  String strTemp3 = null;
		  for (int i=0; i < vRetLanguage.size();i+=5) {%>
          <tr>
            <td height="20" class="thinborder"><font size="1"><%=(String)vRetLanguage.elementAt(i+1)%></font></td>
            <% strTemp = "&nbsp;";strTemp2 = "&nbsp;"; strTemp3 = "&nbsp;";strTemp1 = "&nbsp;";
	if ((String)vRetLanguage.elementAt(i+2)!=null)
		switch(Integer.parseInt((String)vRetLanguage.elementAt(i+2))){
		case 0: strTemp = "<img src=\"../../../images/tick.gif\"> "; break;
		case 1: strTemp1 = "<img src=\"../../../images/tick.gif\"> "; break;
		case 2: strTemp2 = "<img src=\"../../../images/tick.gif\"> "; break;
		case 3: strTemp3 = "<img src=\"../../../images/tick.gif\"> "; break;
		}
%>
            <td align="center" class="thinborder"><font size="1"><%=strTemp%></font></td>
            <td align="center" class="thinborder"><font size="1"><%=strTemp1%></font></td>
            <td align="center" class="thinborder"><font size="1"><%=strTemp2%></font></td>
            <td align="center" class="thinborder"><font size="1"><%=strTemp3%></font></td>
            <td class="thinborder"><div align="center"><font size="1"><%=astrConvFScale[Integer.parseInt((String)vRetResult.elementAt(i+3))]%></font></div></td>
          </tr>
          <%}//end for loop%>
  </table>  
<%}


	if (vRetReference != null && vRetReference.size() > 0) {
%>
<br>
<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" class="thinborder">
<tr>
            <td height="25" colspan="4" class="thinborder"><strong><font color="#FF0000"> REFERENCES :</font></strong></td>
    </tr>
          <tr>
            <td width="32%" height="20" class="thinborder"><font size="1"><strong> Reference </strong></font></td>
            <td width="24%" class="thinborder"><font size="1"><strong>Email Address</strong></font></td>
            <td width="28%" class="thinborder"><font size="1"><strong>Contact Number</strong></font></td>
<!--
            <td width="22%"><font size="1">Relation with the Applicant</font></td>
-->
          </tr>
<%
for(int i = 0; i< vRetReference.size() ; i+= 8){%>
          <tr>
            <td height="20" class="thinborder"><font size="1"><strong><font color="#0000FF"><%=(String)vRetReference.elementAt(i + 1)%></font></strong>
              <%=WI.getStrValue((String)vRetReference.elementAt(i + 3), "<br>","<br>","")%><!--position-->
              <%=WI.getStrValue((String)vRetReference.elementAt(i + 2), "<br>","")%><!--contact address.-->
            </font></td>
            <td class="thinborder"><%=WI.getStrValue(vRetReference.elementAt(i + 4))%></td>
            <td class="thinborder"><%=WI.getStrValue(vRetReference.elementAt(i + 5))%></td>
<!--
            <td><font size="1"> <%=WI.getStrValue(vRetReference.elementAt(i + 6))%></font></td>
-->
          </tr>
<%}%>
  </table>
<%}%> 


<table width="100%" border="0" align="center" cellpadding="2" cellspacing="0">
<tr>
  <td>&nbsp;</td>
</tr>
<tr>
<td><div align="center"><a href="javascript:PrintPage()"><img src="../../../images/print.gif" border="0"></a><font size="1">click to print page</font> </div></td>
</tr>
</table>
  
  <%}//only if Applicant info is not null
 %> 
<input type="hidden" value="1" name="applicant_">
<input type="hidden" name="print_page">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>