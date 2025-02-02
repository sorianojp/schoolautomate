<%@ page language="java" import="utility.*,java.util.Date,iCafe.TimeInTimeOut,java.util.Vector" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Internet Cafe Management Attendance System</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<META HTTP-EQUIV="REFRESH" CONTENT="300; URL=./iL_login.jsp" >
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">

</head>

<script language="JavaScript">
var iFocusCount = 0;
var iTime = <%=new Date().getTime()%>;
	
function focusOnID()
{
	document.esec_record.stud_id.focus();
	iFocusCount = 0;
}
function JSClock() 
{++iFocusCount;
if(iFocusCount >=30)
{
<%
 if (request.getParameter("stud_id") != null && request.getParameter("stud_id").trim().length() > 0) 
 {%>
	this.ClearPage();
<%}%>
} 
   var serverTime = new Date(iTime);
   var hour = serverTime.getHours()
   var minute = serverTime.getMinutes()
   var second = serverTime.getSeconds()
   var temp = "" + ((hour > 12) ? hour - 12 : hour)
   if (hour == 0)
      temp = "12";
   temp += ((minute < 10) ? ":0" : ":") + minute
   temp += ((second < 10) ? ":0" : ":") + second
   temp += (hour >= 12) ? " P.M." : " A.M."

   document.esec_record.dispClk.value=temp;
   iTime += 1000;

//if(document.esec_record.stud_id.value.length ==0)
//	document.esec_record.stud_id.value=(new Date().getHours())+":"+(new Date().getMinutes())+":"+(new Date().getSeconds()+" start time");
   window.setTimeout("JSClock()", 1000);
}
function ClearPage()
{
	location = "./iL_login.jsp";
}
function AddRecord()
{
	document.esec_record.addRecord.value = "1";
}
</script>
<body bgcolor="#6666B3" topmargin="0" onLoad="JSClock();focusOnID();">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	
	String strImgFileExt = null;
	String strRootPath = null;//very important for file method.
	String strErrMsg = null;
	String strTemp = null;
	String strHeight = null;
	String strTimeInTimeOutLabel = null;
	String strComputerNameLabel = null;
	
	String[] astrSchoolYrInfo = null;
	String[] astrConvertSem   = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
	
	int i = 0; 

	String strAttendantID = (String)request.getSession(false).getAttribute("userId");
	if(strAttendantID == null)  {
		strAttendantID = WI.fillTextValue("user_id");
		request.getSession(false).setAttribute("userId",strAttendantID);
	}

	
//add security here.
	try
	{
//		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
	//							"Admin/staff-System Administrator-IP FILTER","ip_filter.jsp");
		dbOP = new DBOperation();
		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");
		strRootPath = readPropFile.getImageFileExtn("installDir");
		
		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
		if(strRootPath == null || strRootPath.trim().length() ==0)
		{
			strErrMsg = "Installation directory path is not set. Please check the property file for installDir KEY.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
/** to avoid session timeout.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"System Administration","IP FILTER",request.getRemoteAddr(),
														"ip_filter.jsp");
if(iAccessLevel == -1)//for fatal error.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../index.htm");
	request.getSession(false).setAttribute("errorMessage",comUtil.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
else if(iAccessLevel == 0)
{
	dbOP.cleanUP();
	response.sendRedirect("../../commfile/unauthorized_page.jsp");
	return;
}
**/
//IP filter authentication added here.
//ADMINISTROTRS,ADMIN STAFF, FACULTY/ACAD. ADMIN, PARENTS/STUDENTS, eDTR(daily time recording)
boolean bolIsStaff = false;
TimeInTimeOut tinStud = new TimeInTimeOut();
Vector vICafeAvalability = tinStud.internetCafeAvailability(dbOP,request.getRemoteAddr());
Vector vRetResult = null;//info about the student.

if(vICafeAvalability == null)//IP error. - not authorized PC for attendance.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../index.htm");
	request.getSession(false).setAttribute("errorMessage",tinStud.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
//end of authenticaion code.

String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null) {
	strSchoolCode = dbOP.getSchoolIndex();
	request.getSession(false).setAttribute("school_code",strSchoolCode);	
}
	
if(WI.fillTextValue("addRecord").compareTo("1") ==0 && WI.fillTextValue("stud_id").length() > 0)
{
	vRetResult = tinStud.autoTimeInTimeOut(dbOP, request);//System.out.println(vRetResult);
	if(vRetResult == null)
		strErrMsg = tinStud.getErrMsg();
	else {	
		if(vRetResult.elementAt(0) == null) {
			bolIsStaff = true;
			vRetResult.removeElementAt(0);
		}
		if(((String)vRetResult.elementAt(vRetResult.size() - 1)).compareTo("0") ==0)
			strTimeInTimeOutLabel = "TIME OUT";
		else
			strTimeInTimeOutLabel = "TIME IN";
		vICafeAvalability = tinStud.internetCafeAvailability(dbOP,request.getRemoteAddr());
	}//System.out.println(vRetResult);
}
	
	if(tinStud.strNewStudID == null)
		strTemp = WI.fillTextValue("stud_id").toUpperCase();
	else
		strTemp = tinStud.strNewStudID.toUpperCase();
		
	if (vRetResult != null && vRetResult.size() > 0)
	{//System.out.println(strRootPath+"upload_img/"+strTemp+"."+strImgFileExt);
		//java.io.File file = new java.io.File(strRootPath+"upload_img/"+strTemp+"."+strImgFileExt);//System.out.println(file.getPath());
		//if(file.exists()) {
			strTemp = "../../upload_img/"+strTemp+"."+strImgFileExt;
			strTemp = "<img src=\""+strTemp+"\" width=400 height=400>"; 
		//}
		//else	
		//	strTemp = "<img src=\"../../images/no_pict_esc.jpg\" width=400 height=400>";
		strHeight = "";
		
		//System.out.println(vRetResult);
	}
	else
	{
		strTemp = 
		"<img src=\"../../images/logo/"+strSchoolCode+".gif\" width=400 height=400>";
		strHeight = "";
	}
	
astrSchoolYrInfo = dbOP.getCurSchYr();
if(astrSchoolYrInfo == null) {
	astrSchoolYrInfo[0] = "School year not set";
	astrSchoolYrInfo[1] ="";
	astrSchoolYrInfo[0] ="0";
}

	
%>

<form name="esec_record" method="post" action="./iL_login.jsp">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td width="49%" valign="top">
	  <table width="100%" border="0" cellspacing="0" cellpadding="5">
          <tr> 
            <td align="center" valign="top" <%=strHeight%>>&nbsp;</td>
            <td <%=strHeight%>>&nbsp;</td>
          </tr>
          <tr> 
            <td width="46%" align="left" valign="top" bordercolor="#FFCC99" <%=strHeight%>><%=strTemp%></td>
            <td width="54%" valign="top" bordercolor="#000000" <%=strHeight%>> <div align="center"> 
                <table width="100%" border="0">
                  <tr> 
                    <td height="30" colspan="2" align="center"><font color="#FFFFFF" size="4"><strong>
					<!--VIRGEN MILAGROSA UNIVERSITY FOUNDATION-->
					<%=utility.SchoolInformation.getSchoolName(dbOP,true,false)%></strong></font></td>
                  </tr>
                  <tr> 
                    <td height="22" colspan="2" align="center"><font color="#FFFFFF" size="2">
					<!--Martin P. Posadas Ave., San Carlos City, Pangasinan -->
					<%=utility.SchoolInformation.getAddressLine1(dbOP,false,false)%></font></td>
                  </tr>
                  <tr> 
                    <td colspan="2" align="center"><font color="#FFFFFF" size="3"><strong>
					(<%=astrSchoolYrInfo[0]%> - <%=astrSchoolYrInfo[1]%>, <%=astrConvertSem[Integer.parseInt(astrSchoolYrInfo[2])]%>)</strong></font></td>
                  </tr>
                  <tr> 
                    <td colspan="2"><hr></td>
                  </tr>
                  <tr> 
                    <td colspan="2">&nbsp;</td>
                  </tr>
                  <tr> 
                    <td width="25%" height="30"><font color="#FFFFFF" size="3">
					<%if(bolIsStaff){%>Employee<%}else{%>Student<%}%> ID:</font></td>
                    <td width="75%"><strong><font color="#FFFF80" size="3">
					<%
					if(tinStud.strNewStudID == null){%>
					<%=WI.fillTextValue("stud_id").toUpperCase()%><%}else{%>
					<%=tinStud.strNewStudID%><%}%></font></strong></td>
                  </tr>
                  <tr> 
                    <td height="30"><font color="#FFFFFF" size="3">Name : </font></td>
                    <td height="30"><strong><font color="#FFFF80" size="3"> 
<%if(vRetResult != null && vRetResult.size() > 0){
	if(bolIsStaff){%>
                      <%=WebInterface.formatName((String)vRetResult.elementAt(1),(String)vRetResult.elementAt(2),
					(String)vRetResult.elementAt(3),4).toUpperCase()%> 
<%}else{%>
                      <%=WebInterface.formatName((String)vRetResult.elementAt(10),(String)vRetResult.elementAt(11),
					(String)vRetResult.elementAt(12),4).toUpperCase()%> 
<%}
}%>
                      </font></strong> </td>
                  </tr>
<%if(!bolIsStaff) {%>
                  <tr> 
                    <td height="30"><font color="#FFFFFF" size="3">Course :</font></td>
                    <td height="30"><strong><font color="#FFFF80" size="3">
<%if(vRetResult != null && vRetResult.size() > 0){%>
                      <%=((String)vRetResult.elementAt(2)).toUpperCase()%> 					
<%}%>
					  </font></strong></td>
                  </tr>
                  <tr> 
                    <td height="30"><font color="#FFFFFF" size="3">Major :</font></td>
                    <td height="30">
<%if(vRetResult != null && vRetResult.size() > 0){%>
                      <%=WI.getStrValue(vRetResult.elementAt(3)).toUpperCase()%> 					
<%}%>
					</td>
                  </tr>
                  <tr> 
                    <td height="30"><font color="#FFFFFF" size="3">Year Level :</font></td>
                    <td height="30"><font color="#FFFF80" size="3"><strong>
<%if(vRetResult != null && vRetResult.size() > 0){%>
                      <%=WI.getStrValue(vRetResult.elementAt(4),"N/A").toUpperCase()%> 					
<%}%>
					</strong></font></td>
                  </tr>
<%}//if(!bolIsStaff) {%>
                  <tr> 
                    <td colspan="2">&nbsp;<font size="3" color="#FFaa00"><b>
					<%
					if(strTimeInTimeOutLabel != null && strTimeInTimeOutLabel.endsWith("IN")){%>
					<%=tinStud.getErrMsg()%><%}%></b></font></td>
                  </tr>
                  <tr> 
                    <td colspan="2"><hr></td>
                  </tr>
                  <tr> 
                    <td colspan="2">&nbsp;</td>
                  </tr>
                  <tr> 
                    <td height="30" colspan="2"><div align="center"><strong><font color="#FFFFFF" size="5"> 
                        ID NO. : </font> 
                        <input name="stud_id"  type="text" size="16" class="textbox"  
	  style="font-size:25;color='red';" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
                        </strong></div></td>
                  </tr>
                  <tr> 
                    <td height="10" colspan="2">&nbsp;</td>
                  </tr>
                  <%if(WI.getStrValue(strTimeInTimeOutLabel).length() > 0){
						boolean bolPlaySound = false;
						strComputerNameLabel = WI.getStrValue((String)vRetResult.elementAt(vRetResult.size() - 2));		  	
				  		if(strSchoolCode.startsWith("AUF") && strComputerNameLabel != null && strTimeInTimeOutLabel.endsWith("IN")){							
							strTimeInTimeOutLabel = "Please proceed to "+strComputerNameLabel+".";
							bolPlaySound = true;
						}
				  %>
				  <tr> 
                    <td height="30" colspan="2" align="center">
					<%if(bolPlaySound){%>
						<embed src="../../wav/<%=strComputerNameLabel%>.wav" autostart="true" loop="false" hidden="true"></embed>
					<%}%>
					<font size="+4" color="red"><strong><%=WI.getStrValue(strTimeInTimeOutLabel)%></strong></font>
					</strong></font></td>
                  </tr>
				  <%}%>
                </table>
              </div></td>
          </tr>
        </table>
        </td>
    </tr>
  </table><br>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr valign="top"> 
		<td align="center" height="35"><font size=+3 color="#FFFF80"><strong>
		<%if(WI.getStrValue(strErrMsg).length() > 0){%>
		<%=strErrMsg%><br><br>
		<%}%></td>
	</tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td width="59%" align="center">&nbsp; 
        <input type=text name="dispClk" size="14"  readonly="yes"
			style="border: 0;Color='#ffffff';
			 font-size:50;background-color: #6666B3;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;"> 
        <input type="image" src="../../images/hidden_btn.gif" onClick="AddRecord();"> 
      </td>
      <td width="41%" align="center">
<%
if(vICafeAvalability != null && vICafeAvalability.size() > 0){%>
	  <table border="0" bgcolor="#000000" cellpadding="1" cellspacing="1">
	  	<tr bgcolor="#FFFFFF">
	  		<td><font size="1"><strong>LOCATION</strong></font></td>
	  		<td><font size="1"><strong>TOTAL SEAT</strong></font></td>
	  		<td><font size="1"><strong>AVAILABLE SEAT</strong></font></td>
	  	</tr>
<%for(int p = 0; p < vICafeAvalability.size(); p += 3){
	if(p == 0)
		strTemp = "#FFFF00";
	else	
		strTemp = "#FFFFFF";
	%>
	  	<tr bgcolor="<%=strTemp%>">
	  		<td><font size="1"><%=(String)vICafeAvalability.elementAt(p)%></font></td>
	  		<td><font size="1"><%=(String)vICafeAvalability.elementAt(p + 1)%></font></td>
	  		<td><font size="1"><%=(String)vICafeAvalability.elementAt(p + 2)%></font></td>
	  	</tr>
<%}//end of for loop%>
	  </table>
<%}// if vICafeAvalability is not null
%>	  </td>
    </tr>
  </table>

<input type="hidden" name="addRecord">
<input type="hidden" name="user_id" value="<%=strAttendantID%>">
</form>


</body>
</html>
<% 	
dbOP.cleanUP(); 
%>
