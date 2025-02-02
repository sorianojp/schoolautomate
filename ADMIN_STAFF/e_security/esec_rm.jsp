<%@ page language="java" import="utility.*,java.util.Date,eSC.TimeInTimeOut,java.util.Vector" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>eSecurity Check</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<META HTTP-EQUIV="REFRESH" CONTENT="300; URL=./esec_rm.jsp" >
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">

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
   window.setTimeout("JSClock()", 990);
}
function ClearPage()
{
	location = "./esec_rm.jsp";
}
function AddRecord()
{
	document.esec_record.addRecord.value = "1";
}
</script>
<body bgcolor="#6666B3" topmargin="0" onLoad="JSClock();focusOnID();" onBlur="focusOnID();">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	
	String strImgFileExt = null;
	String strRootPath = null;//very important for file method.
	String strErrMsg = null;
	String strTemp = null;
	String strHeight = null;
	String strTimeInTimeOutLabel = null;
	
	String[] astrSchoolYrInfo = null;
	String[] astrConvertSem   = {"SUMMER","1ST SEM","2ND SEM","3RD SEM","4TH SEM"};
	
	Vector vRetResult  = null;
	String strUserIndex = null;
		
	int i = 0; 
	
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
IPFilter ipFilter  = new IPFilter();
int iIPAccessLevel = ipFilter.isAuthorizedIP(dbOP,(String)request.getSession(false).getAttribute("userId"), 
                            "eSC(eSecurity Check)","eSecurity Check","CAMPUS ADDENDANCE RECORDING",
							"esec.jsp",request.getRemoteAddr());


if(iIPAccessLevel != 1)//for error while checking.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../index.htm");
	request.getSession(false).setAttribute("errorMessage",ipFilter.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
//end of authenticaion code.
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null) {
	strSchoolCode = dbOP.getSchoolIndex();
	request.getSession(false).setAttribute("school_code",strSchoolCode);
	
}
	
TimeInTimeOut tinStud = new TimeInTimeOut();
boolean bolIsEmployee = false;

if(WI.fillTextValue("addRecord").compareTo("1") ==0 && WI.fillTextValue("stud_id").length() > 0)
{
	vRetResult = tinStud.autoTimeInTimeOut(dbOP, request);
	if(vRetResult == null)
		strErrMsg = tinStud.getErrMsg();
	else {	
		strUserIndex = (String)vRetResult.elementAt(0);
		
		if(WI.getStrValue(vRetResult.elementAt(17)).equals("-1"))
			bolIsEmployee = true;
			
		if(((String)vRetResult.elementAt(vRetResult.size() - 1)).compareTo("0") ==0)
			strTimeInTimeOutLabel = "TIME OUT";
		else	
			strTimeInTimeOutLabel = "TIME IN";
	}
}
	
	strTemp = WI.fillTextValue("stud_id").toUpperCase();
	if (vRetResult != null && vRetResult.size() > 0)
	{//System.out.println(strRootPath+"upload_img/"+strTemp+"."+strImgFileExt);
		if(tinStud.strNewStudID != null)
			strTemp = tinStud.strNewStudID.toUpperCase();
		//System.out.println(strRootPath);
		//java.io.File file = new java.io.File(strRootPath+"upload_img/"+strTemp+"."+strImgFileExt);//System.out.println(file.getPath());
		//if(file.exists()) {
			strTemp = "../../upload_img/"+strTemp+"."+strImgFileExt;
			strTemp = "<img src=\""+strTemp+"\" width=500 height=500>"; 
		//}
		//else	
		//	strTemp = "<img src=\"../../images/no_pict_esc.jpg\" width=500 height=500>";
		strHeight = "";
	}
	else
	{
		strTemp = 
		"<img src=\"../../images/logo/"+strSchoolCode+".jpg\" width=500 height=500>";
		strHeight = "";
	}
	
astrSchoolYrInfo = dbOP.getCurSchYr();
if(astrSchoolYrInfo == null) {
	astrSchoolYrInfo[0] = "School year not set";
	astrSchoolYrInfo[1] ="";
	astrSchoolYrInfo[0] ="0";
}
boolean bolIsBasic = false;
if(!bolIsEmployee && vRetResult != null && vRetResult.elementAt(2) == null) {
	bolIsBasic = true;
	vRetResult.setElementAt(dbOP.getBasicEducationLevel(Integer.parseInt((String)vRetResult.elementAt(4))), 2);
	vRetResult.setElementAt(null,4);
}

if(strErrMsg != null){//removed because it does not work in debian.. needs plugin :O.. %>
	<EMBED SRC="../../jscript/error_attendance.rm" autostart="true" LOOP="false" HIDDEN="true"></EMBED>
<%}%>

<form name="esec_record" method="post" action="./esec_rm.jsp">
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
                    <td width="25%" height="30"><font color="#FFFFFF" size="3">
					<%if(bolIsEmployee){%>Employee ID :<%}else{%>Student ID :<%}%>
					</font></td>
                    <td width="75%"><strong><font color="#FFFF80" size="3">
					<%
					if(tinStud.strNewStudID == null){%>
					<%=WI.fillTextValue("stud_id").toUpperCase()%><%}else{%>
					<%=tinStud.strNewStudID%><%}%></font></strong></td>
                  </tr>
                  <tr> 
                    <td height="30"><font color="#FFFFFF" size="3">Name : </font></td>
                    <td height="30"><strong><font color="#FFFF80" size="3"> 
<%if(vRetResult != null && vRetResult.size() > 0){%>
                      <%=WebInterface.formatName((String)vRetResult.elementAt(10),(String)vRetResult.elementAt(11),
					(String)vRetResult.elementAt(12),4).toUpperCase()%> 
<%}%>
                      </font></strong> </td>
                  </tr>
                  <tr> 
                    <td height="30"><font color="#FFFFFF" size="3">
					<%if(bolIsEmployee){%>College : <%}else{%>Course :<%}%>
					</font></td>
                    <td height="30"><strong><font color="#FFFF80" size="3">
<%if(vRetResult != null && vRetResult.size() > 0){%>
                      <%=WI.getStrValue(((String)vRetResult.elementAt(2)),"").toUpperCase()%> 					
<%}%>
					  </font></strong></td>
                  </tr>
<%if(!bolIsBasic){%>
                  <tr> 
                    <td height="30"><font color="#FFFFFF" size="3">
					<%if(bolIsEmployee){%>Dept : <%}else{%>Major :<%}%>
					</font></td>
                    <td height="30" style="font-weight:bold; color=#FFFF80; font-size:16px">
<%if(vRetResult != null && vRetResult.size() > 0){%>
                      <%=WI.getStrValue(vRetResult.elementAt(3)).toUpperCase()%> 					
<%}%>
					</td>
                  </tr>
<%}if(!bolIsEmployee && !bolIsBasic){%>
                  <tr> 
                    <td height="30"><font color="#FFFFFF" size="3">Year Level :</font></td>
                    <td height="30"><font color="#FFFF80" size="3"><strong>
<%if(vRetResult != null && vRetResult.size() > 0){%>
                      <%=WI.getStrValue(vRetResult.elementAt(4),"N/A").toUpperCase()%> 					
<%}%>
					</strong></font></td>
                  </tr>
<%}%>
                  <tr> 
                    <td colspan="2"><hr></td>
                  </tr>
                  <tr> 
                    <td height="30" colspan="2"><div align="center"><strong><font color="#FFFFFF" size="5">ID NUMBER : </font> 
                        <input name="stud_id"  type="text" size="16" class="textbox"  
	  style="font-size:25;color='red';" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
                        </strong></div></td>
                  </tr>
                  <tr> 
                    <td height="30" colspan="2">
					<%
					if(strUserIndex != null)
						strTemp = new utility.MessageSystem().getSystemMsg(dbOP, strUserIndex, 12);
					else	
						strTemp = null;
					if(strTemp != null){%>
					  <table width="100%" cellpadding="0" cellspacing="0">
						<tr>
						  <td width="2%" height="25">&nbsp;</td>
						  <td width="96%" style="font-size:17px; color:#FFFF00; background-color:#7777aa;" class="thinborderALL"><%=strTemp%></td>
						  <td width="2%">&nbsp;</td>
						</tr>
					 </table>
					<%}else{%>&nbsp;<%}%>
					</td>
                  </tr>
                  <tr> 
                    <td height="30" colspan="2" align="center">
					<font size="+4" color="red"><strong><%=WI.getStrValue(strTimeInTimeOutLabel)%></strong></font>
					<font size=4 color="#FFFF80"><strong><%=WI.getStrValue(strErrMsg)%> 
					</strong></font></td>
                  </tr>
                </table>
              </div></td>
          </tr>
        </table>
        </td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr> 
      <td align="center" bgcolor="#BFD0DF">&nbsp; <input type=text name="dispClk" size="14"  readonly="yes"
			style="border: 0;Color='#000090';
			 font-size:120;background-color: #BFD0DF;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;"> 
        <input type="image" src="../../images/hidden_btn.gif" onClick="AddRecord();"> 
      </td>
    </tr>
  </table>

<input type="hidden" name="addRecord">
</form>


</body>
</html>
<% 	
dbOP.cleanUP(); 
%>
