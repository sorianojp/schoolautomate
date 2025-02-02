<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRInfoEducation" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(5);
//strColorScheme is never null. it has value always.
%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<style type="text/css">
.bgDynamic {
	background-color:<%=strColorScheme[1]%>
}
.footerDynamic {
	background-color:<%=strColorScheme[2]%>
}
</style>

<script language="JavaScript">
function CloseWindow(){ self.close(); }
</script>
</head>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	
	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	
	//This page is called for applicant as well as for employees, -- do not show search button for applicant.
	boolean bolIsApplicant = false;
	if(WI.fillTextValue("applicant_").equals("1"))
		bolIsApplicant = true;

	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").equals("1")) 
		bolMyHome = true;
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Education","hr_personnel_educ_detail.jsp");

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
														"HR Management","PERSONNEL",request.getRemoteAddr(),
														"hr_personnel_educ_detail.jsp");
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){
		if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").compareTo("1") == 0)
			iAccessLevel  = 2;
		else 
			iAccessLevel = 1;

		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	}
}

if (strTemp == null) 
	strTemp = "";
//
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
Vector vEmpRec = null;
Vector vEditResult = null;
String strPrepareToEdit = null;

String strInfoIndex = WI.fillTextValue("info_index");

HRInfoEducation hrEduc = new HRInfoEducation();

strTemp = WI.fillTextValue("emp_id");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);

if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0){
	request.setAttribute("emp_id",strTemp);
}


if(bolIsApplicant){
	hr.HRApplNew hrApplNew = new hr.HRApplNew();
	vEmpRec = hrApplNew.operateOnApplication(dbOP, request,3);//view one
	if (vEmpRec == null || vEmpRec.size() == 0)
		strErrMsg = hrApplNew.getErrMsg();

}else{	
	enrollment.Authentication authentication = new enrollment.Authentication();
	vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	if(vEmpRec == null || vEmpRec.size() ==0)
		strErrMsg = authentication.getErrMsg();
}

vRetResult = hrEduc.operateOnEducation(dbOP,request, 3);
if (vRetResult == null) strErrMsg = hrEduc.getErrMsg();

%>
<body bgcolor="#663300" class="bgDynamic">
<form action="./hr_personnel_educ_detail.jsp" method="post" name="staff_profile">

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td width="100%" height="25" colspan="4" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          EDUCATIONAL RECORDS PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25">&nbsp;<font size=3><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
  </table>
<% if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){ %>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td colspan="2"><a href="javascript:CloseWindow();"><img src="../../../images/close_window.gif" width="71" height="32" border="0" align="right"></a>
        <% if (!WI.fillTextValue("applicant_").equals("1")) {%>
        <table width="400" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> 
              <%strTemp = "<img src=\"../../../upload_img/"+strTemp.toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=\"1\">";%>
              <%=WI.getStrValue(strTemp)%> <br> <br> 
              <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}
%>
              <br> <strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font><br> 
              <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> <br>
			<% if (!bolIsApplicant) {%>
			  <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
              <%="Length of Service : <br>" + new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></font> 
			 <%}%>
            </td>
          </tr>
        </table>
<%}else{%>
        <table width="400" height="77" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> 
              <%strTemp = "<img src=\"../../../faculty_img/"+WI.fillTextValue("emp_id").toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\">";%>
              <%=strTemp%><br> <br> <br> <strong><%=WI.formatName((String)vEmpRec.elementAt(1),
			  								(String)vEmpRec.elementAt(2),
						 				    (String)vEmpRec.elementAt(3),4)%></strong><br>
              Position Applying for: <%=WI.getStrValue(vEmpRec.elementAt(11))%><br> 
              <%=WI.getStrValue(vEmpRec.elementAt(5),"<br>","")%> 
              <!-- email -->
              <%=WI.getStrValue(vEmpRec.elementAt(4))%> 
              <!-- contact number. -->
            </td>
          </tr>
        </table>
<%}%>
<br>
<table width="100%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
          <tr> 
            <td width="20%" height="26" class="thinborder">Education</td>
            <td width="80%" class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(21)%></td>
          </tr>
          <tr> 
            <td height="25" class="thinborder">Name of School</td>
            <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(22))%></td>
          </tr>
          <tr> 
            <td height="25" class="thinborder">School Address</td>
            <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(23))%></td>
          </tr>
          <tr> 
            <td height="25" class="thinborder">Degree Earned</td>
            <td class="thinborder">&nbsp;
			<% if (WI.getStrValue((String)vRetResult.elementAt(27),"0").equals("1")){%>
				(Completed Academic Requirements)
			<%}%>
			<%=WI.getStrValue((String)vRetResult.elementAt(2))%> </td>
          </tr>
          <tr> 
            <td height="25" class="thinborder">Date Graduated</td>
            <td  class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(3),"--") + "/" +
		  	 WI.getStrValue((String)vRetResult.elementAt(14),"--")  + "/" +
			 WI.getStrValue((String)vRetResult.elementAt(15),"--")%></td>
          </tr>
          <tr> 
            <td height="25"  class="thinborder">No. of Units Completed</td>
            <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(4))%></td>
          </tr>
          <tr> 
            <td height="25" class="thinborder">Dissertation/Thesis</td>
            <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(5))%> 
			<% if (WI.getStrValue((String)vRetResult.elementAt(6)).compareTo("1") == 0){%><%="<em>(Published)</em>"%><%}%>
			</td>
          </tr>
<%if(!strSchCode.startsWith("CPU")) {%>
          <tr> 
            <td height="25" class="thinborder">General Weighted <br>
              Average </td>
            <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(7))%></td>
          </tr>
<%}%>
          <tr> 
            <td rowspan="2" class="thinborder">Inclusive Date of Attendance</td>
            <td height="25" class="thinborder">From : <%=WI.getStrValue((String)vRetResult.elementAt(8),"--") + "/" +    
			 WI.getStrValue((String)vRetResult.elementAt(16),"--")  + "/" + 
			 WI.getStrValue((String)vRetResult.elementAt(17),"--")%></td>
          </tr>
          <tr> 
            <td height="25" class="thinborder">To:&nbsp;&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(9),"--") + "/" + 
			 WI.getStrValue((String)vRetResult.elementAt(18),"--") + "/" + 
			 WI.getStrValue((String)vRetResult.elementAt(19),"--")%></td>
          </tr>
          <tr> 
            <td height="25" class="thinborder">Graduation Honors</td>
            <td class="thinborder">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(24))%></td>
          </tr>
          <tr> 
            <td height="25" colspan="2" class="thinborder">Awards: &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(11))%></td>
          </tr>
          <tr> 
            <td height="25" colspan="2" class="thinborder"> Remarks: &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(12))%></td>
          </tr>
        </table>

      </td>
 </tr>
</table>
<%}%>
<table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>
<input type="hidden" name="info_index" value="<%=strInfoIndex%>">
<input type="hidden" name="applicant_" value="<%=WI.fillTextValue("applicant_")%>">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
