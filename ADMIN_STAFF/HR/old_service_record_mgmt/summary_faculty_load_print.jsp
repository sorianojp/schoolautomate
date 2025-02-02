<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Untitled Document</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<link href="../../../css/reportlink.css" rel="stylesheet" type="text/css">
</head>
<%@ page language="java" import="utility.*,java.util.Vector, hr.HRInfoContact, hr.HRInfoEducation, hr.HRInfoLicenseETSkillTraining, hr.OldServiceRecord, enrollment.Authentication"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;
	String strSubCode = "";
	String strRecIndex = null;
	String [] astrSem = {"Summer", "1st Semester", "2nd Semester", "3rd Semester"};	
//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-OLD SERVICE RECORD MGMT","old_service_record_mgmt.jsp");

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
														"HR Management","OLD SERVICE RECORD MGMT",request.getRemoteAddr(),
														"old_service_record_mgmt.jsp");
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
Vector vEmpRec = null;
Vector vServiceRecord = null;
Vector vLoad = null;
Vector vContactDetail = null;
Vector vEducation = null;
Vector vLicense = null;

String strInfoIndex = request.getParameter("info_index");

Authentication auth = new Authentication();


strTemp = WI.fillTextValue("emp_id");


if (strTemp.length()> 0){
	
	HRInfoContact HRContact = new HRInfoContact();
	HRInfoEducation HREduc = new HRInfoEducation();
	HRInfoLicenseETSkillTraining HRSkills =  new HRInfoLicenseETSkillTraining();
	enrollment.Authentication authentication = new enrollment.Authentication();
   
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
	vContactDetail = HRContact.operateOnPermAddress(dbOP,request,4);
	vEducation = HREduc.operateOnEducation (dbOP, request, 4);
	vLicense = HRSkills.operateOnLicense(dbOP, request,4);

	if (vEmpRec == null || vEmpRec.size() == 0){
		if (strErrMsg == null || strErrMsg.length() == 0)
			strErrMsg = authentication.getErrMsg();
	}
}
OldServiceRecord oSR = new OldServiceRecord();

vServiceRecord = oSR.operateOnOldServiceRecord(dbOP, request, 4);

strTemp = WI.fillTextValue("page_action");
if(strTemp.length() > 0) {
	if(oSR.operateOnOldServiceRecord(dbOP, request, Integer.parseInt(strTemp)) != null ) {
		strErrMsg = "Operation successful.";
	}
	else
		strErrMsg = oSR.getErrMsg();
}



if (vServiceRecord!=null){
	strRecIndex  = (String)vServiceRecord.elementAt(0);
	vLoad = oSR.operateOnOldServiceRecord (dbOP, request, 6);
			if (vLoad ==null)
				strErrMsg = oSR.getErrMsg();
}
else
	strErrMsg = oSR.getErrMsg();
%>

<body>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td width="100%"><div align="center"> 
        <p><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%> </strong><br>
          <%=SchoolInformation.getAddressLine1(dbOP,false,false)%>,<%=SchoolInformation.getAddressLine2(dbOP,false,false)%> <br>
          <%=SchoolInformation.getAddressLine3(dbOP,false,false)%> <br>
          <strong> <%=SchoolInformation.getInfo2(dbOP,false,false)%></strong> <br>
      </p></div></td>
    </tr>
    <tr> 
      <td height="14" colspan="2"><div align="center">HUMAN RESOURCE MANAGEMENT 
          OFFICE</div></td>
    </tr>
    <tr> 
      <td height="25" colspan="2"><div align="center"><strong>EMPLOYEE SERVICE 
          RECORD</strong></div></td>
    </tr>
    <tr> 
      <td height="18" colspan="2">&nbsp;</td>
    </tr>
</table>
	
  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
     <tr bgcolor="#FFFFFF">
<td width="20%">&nbsp;</td>
            <td width="60%" valign="middle" bgcolor="#FFFFFF" colspan="2">
              <%strTemp = WI.fillTextValue("emp_id");%>
              <%strTemp = "<img src=\"../../../upload_img/"+strTemp.toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=\"1\">";%>
              <%=WI.getStrValue(strTemp)%> <br> <br>
              <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 = (String)vEmpRec.elementAt(13);
		strTemp3 +=  WI.getStrValue((String)vEmpRec.elementAt(14),"/","","");
	}
%>
              <br> <strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font><br>
              <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> <br> <font size=1><%="Date Hired : "  + (String)vEmpRec.elementAt(6)%><br>
              <%="Length of Service : <br> " + new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></font>
            </td>
            <td width="20%">&nbsp;</td>
    </tr>
    <tr> 
      <td height="38">&nbsp;</td>
       <%strTemp = (String)vEmpRec.elementAt(5);%>
      <td >Date of Birth : <strong><%=strTemp%></strong></td>
      <td >Age : <strong><%=CommonUtil.calculateAGEDatePicker(strTemp)%></strong></td>
      <td >&nbsp;</td>
    </tr>
  </table>  

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td width="19%" height="25" class="thinborder">Home Address</td>
      <td width="41%" class="thinborder"> <%if (vContactDetail!=null && vContactDetail.size()>0){%> <%=WI.getStrValue((String)vContactDetail.elementAt(1))%>&nbsp; <%=WI.getStrValue((String)vContactDetail.elementAt(2))%>&nbsp; <%=WI.getStrValue((String)vContactDetail.elementAt(3))%> <%}else{%> &nbsp; <%}%> </td>
      <td width="40%" class="thinborder"><%if (vEducation!=null && vEducation.size()>0){%>
        Degree Obtained : <%=(String)vEducation.elementAt(2)%> <%}else{%> &nbsp; <%}%></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder">Current Address</td>
      <td class="thinborder" colspan="2"><%=(String)vEmpRec.elementAt(8)%></td>
    </tr>
    <tr> 
      <td height="25" class="thinborder">Contact Nos.</td>
      <td class="thinborder"><%=(String)vEmpRec.elementAt(7)%></td>
      <td class="thinborder"><%if (vEducation!=null && vEducation.size()>0){%> 
	  When Obtained : <%=WI.getStrValue((String)vEducation.elementAt(3)," - ")%>/<%=WI.getStrValue((String)vEducation.elementAt(14),"-")%>/<%=WI.getStrValue((String)vEducation.elementAt(15),"-")%> <%}else{%> &nbsp; <%}%></td>
    </tr>
    <tr> 
      <td height="27" colspan="3" class="thinborder">License Exams Passed : 
        <%if (vLicense!=null && vLicense.size()>0){%> <%for (int i = 0; i<vLicense.size();i+=8){%> <%=(String)vLicense.elementAt(i+1)%> <%}%> <%}else{%> &nbsp; <%}%></td>
    </tr>
  </table><br><br>
<%
if (vLoad!=null && vLoad.size()>0){%>
<table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="6" class="thinborder"><div align="center"><strong>OLD 
          SERVICE RECORD ENTRIES</strong></div></td>
    </tr>
    <tr> 
      <td width="14%" height="25" class="thinborder"><div align="center"><strong>SCHOOL YEAR</strong></div></td>
      <td width="17%" class="thinborder"><div align="center"><strong>TERM</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>TOTAL LOAD</strong></div></td>
      <td width="42%" class="thinborder"><div align="center"><strong>SUBJECTS</strong></div></td>
      <td width="10%" class="thinborder"><div align="center"><strong>SERVICE CREDIT</strong> </div></td>
      <td width="7%" class="thinborder"><strong>TOTAL CREDIT</strong> </td>
    </tr>
<%	double dTotalCredit = 0d;
	String strServiceCredit = null;
	
//	System.out.println("vLoad : " + vLoad);
	
	for (int i = 0; i< vLoad.size(); i+=10){
	strServiceCredit = (String)vLoad.elementAt(i+9);
	dTotalCredit += Double.parseDouble(WI.getStrValue(strServiceCredit,"0"));
	strTemp = (String)vLoad.elementAt(i+1);%>
    <tr> 
      <td height="25" class="thinborder"><div align="center"><font size="1"><%=(String)vLoad.elementAt(i+2)%>&nbsp;-&nbsp;<%=(String)vLoad.elementAt(i+3)%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1">
      <%=astrSem[Integer.parseInt((String)vLoad.elementAt(i+4))]%></font></div></td>
      <td class="thinborder"><div align="center"><font size="1"><%=(String)vLoad.elementAt(i+5)%></font></div></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vLoad.elementAt(i+7), (String)vLoad.elementAt(i+8))%>
      <% for (i += 10;i< vLoad.size(); i+=10){
      if ( ((String)vLoad.elementAt(i+1)).compareTo(strTemp) == 0 ){%>
      ,<%=WI.getStrValue((String)vLoad.elementAt(i+7), (String)vLoad.elementAt(i+8))%>
      <%}else{
      		i-=10;
	      break;
	    }
	 }%>
      </font></td>
      <td class="thinborder">&nbsp;<%=WI.getStrValue(strServiceCredit,"-")%></td>
      <td class="thinborder">&nbsp;<%=CommonUtil.formatFloat(dTotalCredit,true)%></td>
    </tr>
    <%}%>
  </table>
  <script language="JavaScript">
window.print();
</script> 
<%}%>
</body>
</html>
<%
dbOP.cleanUP();
%>
