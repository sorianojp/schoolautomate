<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoPersonalExtn,enrollment.Authentication"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
boolean bolIsGovernment = false;
String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
if(strSchCode == null)
	strSchCode = "";
boolean bolAUF = strSchCode.startsWith("AUF");
%>
	
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Personnel Record</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
</head>
<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;

	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").compareTo("1") == 0) 
		bolMyHome = true;

//add security hehol.
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Personal Data","hr_personnel_personal_data.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		bolIsGovernment = (readPropFile.getImageFileExtn("IS_GOVERNMENT","0")).equals("1");

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
														"hr_personnel_personal_data.jsp");
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

boolean bolFatalErr = false;
String strInfoIndex = WI.fillTextValue("info_index");

HRInfoPersonalExtn hrPx = new HRInfoPersonalExtn();
Authentication auth = new Authentication();

int iAction =  -1;

iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"0"));

strTemp = WI.fillTextValue("emp_id");

if (strTemp.length()> 0){
	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");

	if (vEmpRec == null || vEmpRec.size() == 0){
		if (strErrMsg == null || strErrMsg.length() == 0)
			strErrMsg = authentication.getErrMsg();
	}
	vRetResult = hrPx.operateOnPersonalData(dbOP,request,0);

	if (vRetResult == null || vRetResult.size()==0){
		if (strErrMsg == null || strErrMsg.length() == 0)
			strErrMsg = hrPx.getErrMsg();
	}
}

String[] astrGender ={"Male", "Female"};
String[] astrCStatus = {" &nbsp;", "Single", "Married", "Divorced/Separated","Widow/Widower","Annuled","Living Together"};
String[] astrBloodType = {" Not Known", "A","B", "AB", "O"};
%>
<body>
<div align="center"><strong><%=SchoolInformation.getSchoolName(dbOP,true,false)%></strong><br>
  <%=SchoolInformation.getAddressLine1(dbOP,false,false)%><br>
  <%=SchoolInformation.getInfo1(dbOP,false,false)%> <br>
  <br>
</div>
<table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td width="100%" height="25"> <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
	  	<%=WI.getStrValue(strErrMsg)%>
        <% if (vEmpRec != null && vEmpRec.size() > 0) {%>
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
              <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> <br> <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
              <%if(bolAUF){%>
			  	<%=WI.getStrValue(new hr.HRUtil().getServicePeriodLengthPT(dbOP,(String)vEmpRec.elementAt(0)), "Part-time years of service: ", "<br>", "")%>
				<%=WI.getStrValue(new hr.HRUtil().getServicePeriodLengthFT(dbOP,(String)vEmpRec.elementAt(0)), "Full-time years of service: ", "<br>", "")%>
				<%=WI.getStrValue(new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0)), "Total years of service: ", "", "")%>
			  <%}else{%>
             	 <%="Length of Service : <br>" + new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%>
			  <%}%></font> 
            </td>
          </tr>
        </table>

        <br>
<table bgcolor="#FFFFFF" width="95%" border="0" cellspacing="0" cellpadding="0">
          <tr> 
            <td  width="2%" height="25">&nbsp;</td>
            <td width="20%">Name </td>
            
          <td width="78%" colspan="2"> : &nbsp;<%=WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2),
											(String)vEmpRec.elementAt(3),4)%> </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td>Gender</td>
            
          <td colspan="2"> : &nbsp;<%=astrGender[Integer.parseInt(WI.getStrValue((String)vEmpRec.elementAt(4),"0"))]%>
			</td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td>Birth Date</td>
            
          <td colspan="2"> : &nbsp;
<% strTemp = WI.getStrValue((String)vEmpRec.elementAt(5), "");
				if (strTemp.length() > 0) 
					strTemp = WI.formatDate(strTemp, 6);		
			%> <%=strTemp%> 
            </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25">Age</td>
            
          <td height="25" colspan="2">: &nbsp;<%=WI.fillTextValue("age")%></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25"><font size="2">Date Hired</font></td>
            
          <td height="25" colspan="2">: &nbsp; 
            <%	strTemp = WI.getStrValue(vEmpRec.elementAt(6), "");
				if (strTemp.length() > 0) 
					strTemp = WI.formatDate(strTemp, 6);%> <%=strTemp%>
            </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25">Contact Nos.</td>
            
          <td height="25" colspan="2"> : &nbsp;<%=WI.getStrValue((String)vEmpRec.elementAt(7))%></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25">Address</td>
            
          <td height="25" colspan="2"> : &nbsp;<%=WI.getStrValue((String)vEmpRec.elementAt(8))%></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25">Email Address</td>
            
          <td height="25" colspan="2"> : &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(21))%></td>
          </tr>
          <tr> 
            <td  colspan="4"height="10"><hr size="1"></td>
          </tr>
        </table>
        <table bgcolor="#FFFFFF" width="95%" border="0" cellspacing="0" cellpadding="0">
<% if (strSchCode.startsWith("AUF")) { 

 if(!bolFatalErr) 
		strTemp = WI.getStrValue((String)vEmpRec.elementAt(25));
	else if (!bolCleanUp) 
		strTemp = WI.fillTextValue("salary_grade"); 
	else
		strTemp = "";
%>
 <%}%> 
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td width="20%">Position</td>
            
          <td width="78%"> : &nbsp;
<%  
	strTemp = (String)vEmpRec.elementAt(9);
	if (strTemp  != null) 
		strTemp = dbOP.mapOneToOther("HR_EMPLOYMENT_TYPE", "EMP_TYPE_INDEX",strTemp,"EMP_TYPE_NAME"," and is_del = 0");	
%> <%=WI.getStrValue(strTemp)%>            </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25">Employment Status</td>
            
          <td height="25"> : &nbsp;
<%  strTemp = (String)vEmpRec.elementAt(10);
	if (strTemp != null) 
		strTemp = dbOP.mapOneToOther("user_status", "status_index", strTemp, "status", "");
%> <%=WI.getStrValue(strTemp)%>			</td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
            
          <td height="25"> : &nbsp;
<% strTemp = strTemp = (String)vEmpRec.elementAt(11);
	if (strTemp != null) 
		strTemp = dbOP.mapOneToOther("college", "c_index", strTemp, "c_name", " and is_del = 0");
%> <%=WI.getStrValue(strTemp)%>            </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25">Office/Department</td>
            
          <td height="25"> : &nbsp;
<% strTemp = (String)vEmpRec.elementAt(12);
	if (strTemp != null)
		strTemp = dbOP.mapOneToOther("department", "d_index", strTemp, "d_name", " and is_del=0");
%> <%=WI.getStrValue(strTemp)%>			</td>
          </tr>
          <tr> 
            <td height="10" colspan="3"><hr size="1"></td>
          </tr>
        </table>
        <table width="95%" border="0" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td width="20%" height="25">Civil Status</td>
            
          <td width="78%" height="25"> : &nbsp;<%=astrCStatus[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(0),"0"))]%>            </td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Place of Birth</td>
            
          <td height="25">: &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(1))%></td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Nationality</td>
            
          <td height="25"> : &nbsp;
<% strTemp = (String)vRetResult.elementAt(2);
	if (strTemp != null)
		strTemp = dbOP.mapOneToOther("HR_PRELOAD_NATIONALITY", "NATIONALITY_INDEX", strTemp, "NATIONALITY", "");
%> <%=WI.getStrValue(strTemp)%>            </td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Religion</td>
            
          <td height="25"> : &nbsp;
<% strTemp = (String)vEmpRec.elementAt(12);
	if (strTemp != null)
		strTemp = dbOP.mapOneToOther("HR_PRELOAD_RELIGION", "RELIGION_INDEX", strTemp, "RELIGION", "");
%> <%=WI.getStrValue(strTemp)%>            </td>
          </tr>
          <tr>
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">SSS Number</td>
            
          <td height="25">: &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(4))%></td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">TIN </td>
            
          <td height="25">: &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(5))%></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25">Philhealth</td>
            
          <td height="25">: &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(16))%></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25">Pag-ibig</td>
            
          <td height="25">: &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(17))%></td>
          </tr>
					<% if (bolIsSchool && !bolIsGovernment) {%>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25">PERAA</td>
            
          <td height="25">: &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(18))%></td>
          </tr>					
					<%}%>
					<%if(bolIsGovernment){%>
          <tr>
            <td height="25">&nbsp;</td>
            <td height="25">&nbsp;</td>
            <td height="25">: &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(24))%></td>
          </tr>
					<%}%>
          <tr> 
            <td colspan="3"><hr size="1"></td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Father's Name</td>
            
          <td height="25">: &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(6))%>
              &nbsp;&nbsp;&nbsp; 
			<% if (WI.getStrValue((String)vRetResult.elementAt(19),"1").equals("0")){%>(Deceased)<%}%>			</td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Occupation</td>
            
          <td height="25">: &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(7))%></td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Mother's Name</td>
            
          <td height="25">: &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(8))%>
              &nbsp;&nbsp;&nbsp; 
			<% if (WI.getStrValue((String)vRetResult.elementAt(20),"1").equals("0")) {%> (Deceased) <%}%>			</td>
          </tr>
		  <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Occupation</td>
            
          <td height="25">: &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(9))%></td>
          </tr>
          <tr> 
            <td height="10" colspan="3"><hr size="1"></td>
          </tr>
	      <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Height (in cms)</td>
            
          <td height="25">: &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(10))%></td>
        </tr>
        <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Weight (in lbs)</td>
            
          <td height="25">: &nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(11))%>            </td>
        </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">Blood Type</td>
            
          <td height="25"> : &nbsp;
<% strTemp = astrBloodType[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(12),"0"))];
	if (astrBloodType[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(12),"0"))].equals("0"))
			strTemp = "";
	else
		strTemp = WI.getStrValue((String)vRetResult.elementAt(13));

	if (strTemp.length() > 0){
		if (strTemp.equals("0"))
			strTemp = "&nbsp; +";
		else
			strTemp = "&nbsp; -";
	}
%><%=astrBloodType[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(12),"0"))] + strTemp%>			</td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25">Distinguising Marks</td>
            
          <td height="25">: &nbsp;<%= WI.getStrValue((String)vRetResult.elementAt(22),"none")%></td>
          </tr>
          <tr> 
            <td width="2%" height="25">&nbsp;</td>
            <td height="25">&nbsp;</td>
            <td height="25">&nbsp;</td>
          </tr>
        </table>
<%}%>
      </td>
</tr>
</table>
<script language="JavaScript">
window.setInterval("javascript:window.print()", 0);
</script>

</body>
</html>
<%
	dbOP.cleanUP();
%>
