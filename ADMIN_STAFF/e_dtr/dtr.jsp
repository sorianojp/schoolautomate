<%@ page language="java" import="utility.*, java.util.Date, eDTR.TimeInTimeOut, java.util.Calendar, java.util.Vector" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>E DTR</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<META HTTP-EQUIV="REFRESH" CONTENT="300; URL=./dtr.jsp" >
<link href="../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript">
var iFocusCount = 0;
var iTime = <%=new Date().getTime()%>;
	
function focusOnID()
{
	document.dtr_record.emp_id.focus();
	iFocusCount = 0;
}
function JSClock() 
{++iFocusCount;
if(iFocusCount >=30)
{
<%
 if (request.getParameter("emp_id") != null && request.getParameter("emp_id").trim().length() > 0) 
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

   document.dtr_record.dispClk.value=temp;
   iTime += 1000;

//if(document.dtr_record.emp_id.value.length ==0)
//	document.dtr_record.emp_id.value=(new Date().getHours())+":"+(new Date().getMinutes())+":"+(new Date().getSeconds()+" start time");
   window.setTimeout("JSClock()", 1000);
}
function ClearPage()
{
	location = "./dtr.jsp";
}
function AddRecord()
{
	document.dtr_record.addRecord.value = "1";
}
function PageSubmit(e, cursorLoc) {
	if(e.keyCode == 13) {
		if(document.dtr_record.emp_id.value == '')
			return;
			
		if(cursorLoc == '1') {
			if(document.dtr_record.pswd_)
				document.dtr_record.pswd_.focus();
			else	
				cursorLoc = '2';
		}
		if(cursorLoc == '2') {
			document.dtr_record.addRecord.value = "1";	
			document.dtr_record.submit();
		}	
	}
}
</script>
<body bgcolor="#6666FF" topmargin="0" onLoad="JSClock();focusOnID();">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);

	
	String strImgFileExt = null;
	String strRootPath = null;//very important for file method.
	String strErrMsg = null;
	String strTemp = null;
	String strHeight = null;
	String strTimeInTimeOutLabel = null;
	
	Vector vTimeInList = null;
	Vector vTimeOutList = null;
	Vector vEmployeeRecords  = null;
	
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
		//I must check if this DTR page is allowed for login.. 
		//strTemp = "select EDTR_FS from FS_SETTING";
		//strTemp = dbOP.getResultOfAQuery(strTemp, 0);
		//System.out.println(strTemp);
		//if(strTemp == null || !strTemp.equals("0")) {
		//	dbOP.cleanUP();
		//	strErrMsg = "Failed in Launching. Please use Standalone PC set up for time in/out.";
		//	throw new Exception();
		//}
	}
	catch(Exception exp)
	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in connection. Please try again.";
		%>
		<p align="center"><br><br><br><br> <font face="Verdana, Arial, Helvetica, sans-serif" size="4" color="#CCFF00"><b><%=strErrMsg%></b></font></p>
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
//check read property file if it is allowed.. 
String strDTRAllowStat = "select prop_val from read_property_file where prop_name = 'ENABLE_DTR_WEB'";
strDTRAllowStat = dbOP.getResultOfAQuery(strDTRAllowStat, 0);
if(strDTRAllowStat == null)
	strDTRAllowStat = "0";
if(strDTRAllowStat.equals("0")) {
	dbOP.cleanUP();
	%>
		<p align="center"><br><br><br><br> <font face="Verdana, Arial, Helvetica, sans-serif" size="4" color="#CCFF00"><b>Page not available</b></font></p>
	<%return;
}


IPFilter ipFilter  = new IPFilter();
int iIPAccessLevel = ipFilter.isAuthorizedIP(dbOP,null, 
                            "eDTR(daily time recording)","eDaily Time Record","DAILY TIME RECORDING",
							"dtr.jsp",request.getRemoteAddr());

if(iIPAccessLevel != 1)//for error while checking.
{
	dbOP.cleanUP();
	request.getSession(false).setAttribute("go_home","../index.htm");
	request.getSession(false).setAttribute("errorMessage",ipFilter.getErrMsg());
	response.sendRedirect("../../commfile/fatal_error.jsp");
	return;
}
//end of authenticaion code.
TimeInTimeOut tinEmployee = new TimeInTimeOut();
  tinEmployee.setLocIndex("11");

if(WI.fillTextValue("addRecord").compareTo("1") ==0 && WI.fillTextValue("emp_id").length() > 0) {
	//I have to check if password is must.. 
	strErrMsg = null;
	if(strDTRAllowStat.equals("2")) {
		String strPassword = WI.fillTextValue("pswd_");
		if(strPassword.length() == 0)
			strErrMsg = "Password can't be empty. Please enter password.";
		else {
			strTemp = "select password from login_info join user_table on (user_table.user_index = login_info.user_index) where id_number = '"+
				ConversionTable.replaceString(WI.fillTextValue("emp_id"), "'", "")+"'";
			strTemp = dbOP.getResultOfAQuery(strTemp, 0);
			if(strTemp == null)
				strErrMsg = "ID number does not exist.";
			else if(!strTemp.equals(strPassword))
				strErrMsg = "Password does not match";
		}
	}
	if(strErrMsg == null) {
		Calendar calendar = Calendar.getInstance();
		//vEmployeeRecords = tinEmployee.autoTimeInTimeOut(dbOP,request);
		vEmployeeRecords = tinEmployee.autoTimeInTimeOut(dbOP,request, calendar, null, false, null);
		//vEmployeeRecords = tinEmployee.autoTimeInTimeOut(dbOP,request, calendar, null, false, null, "0", "-1");
		//System.out.println("one oi!!!");
		//vEmployeeRecords = tinEmployee.autoTimeInTimeOut(dbOP,request, calendar, null, false, null, "1", "-1");
		
		if (vEmployeeRecords !=null){
			strTimeInTimeOutLabel = (String)vEmployeeRecords.elementAt(21);
			strUserIndex = (String)vEmployeeRecords.elementAt(0);
		}
	}
}
if(tinEmployee.getErrMsg() != null)
	strErrMsg = tinEmployee.getErrMsg();
String strSchoolCode = (String)request.getSession(false).getAttribute("school_code");
if(strSchoolCode == null)
	strSchoolCode = dbOP.getSchoolIndex();

%>
<form name="dtr_record" method="post" action="./dtr.jsp" autocomplete="off">
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td bgcolor="#A3C1D1" height="27"><div align="center"><strong><font color="#FFFFFF" size="3">TIME -IN LIST</font></strong></div></td>
      <td width="49%" valign="top" bgcolor="#A3C1D1">&nbsp; </td>
      <td height="27" bgcolor="#A3C1D1"><div align="center"><font color="#FFFFFF" size="3"><strong>TIME - OUT LIST </strong></font></div></td>
    </tr>
    <tr> 
      <td width="26%" valign="top"> <div align="center"><strong></strong></div>
        <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#D2E1D1" >
          <tr bgcolor="#336699"> 
            <td width="47%" ><div align="center"><strong><font color="#FFFFFF">EMPLOYEE 
                ID </font></strong></div></td>
            <td width="53%" height="20"><strong><font color="#FFFFFF">MM-DD ::</font></strong><font color="#FFFFFF"><strong>TIME</strong></font></td>
          </tr>
          <%	
	if(false)
		vTimeInList = tinEmployee.getLastTimeInTimeOutList(dbOP, true);
		
	if (vTimeInList!=null && vTimeInList.size() > 0) {
	 	for (i= 0; i<vTimeInList.size() ; i+=3){
			if (i == 0){ %>
          <tr bgcolor="#75B3AF"> 
            <td height="18"><b><font size=3 color><%=(String)vTimeInList.elementAt(i+2)%></font></b></td>
            <td height="18"><b><%=(String)vTimeInList.elementAt(i)%></b></td>
            <%}else{%>
          <tr> 
            <td height="18"><%=(String)vTimeInList.elementAt(i+2)%></td>
            <td height="18"><%=(String)vTimeInList.elementAt(i)%></td>
            <%}%>
          </tr>
          <%		} 
	}
%>
        </table>
        <div align="center"><br>
          <font color="#FF0000" size="7"><strong> 
          <%
 if ((strTimeInTimeOutLabel!=null) && (strTimeInTimeOutLabel.trim().length() > 1) 
 		&& (strTimeInTimeOutLabel.compareTo("Time In")==0)){
%>
          <%=strTimeInTimeOutLabel%> 
          <%}%>
          &nbsp; </strong></font></div></td>
      <td width="48%" valign="top"><table width="100%" border="0" cellspacing="0" cellpadding="4">
          <tr> 
            <% 
	
	strTemp = WI.fillTextValue("emp_id");
	if (dbOP.strBarcodeID != null) 
		strTemp = dbOP.strBarcodeID;

	strTemp = strTemp.toUpperCase();
	
	if ((strTemp.length() > 0) && (vEmployeeRecords!=null))
	{//System.out.println(strRootPath+"upload_img/"+strTemp+"."+strImgFileExt);
		//java.io.File file = new java.io.File(strRootPath+"upload_img/"+strTemp+"."+strImgFileExt);//System.out.println(file.getPath());
		//if(file.exists()) {
			strTemp = "../../upload_img/"+strTemp+"."+strImgFileExt;
			strTemp = "<img src=\""+strTemp+"\" width=400 height=400>"; 
		//}
		//else	
		//	strTemp = "<img src=\"../../images/no_pict_edtr.jpg\" width=400 height=400>";
		strHeight = "";
	}
	else
	{
		strTemp = "<img src=\"../../images/logo/"+strSchoolCode+".jpg\" width=400 height=400>";
		strHeight = "";
	}
	
%>
            <td colspan="2" <%=strHeight%>> 
              <div align="center"><%=strTemp%></div></td>
          </tr>
          <tr> 
            <td width="28%" height="25"><font color="#FFFFFF">Emp. ID # : </font><font color="#FFFFFF" size="3">&nbsp;</font></td>
            <td width="72%"><font color="#FFFFFF" size="3"><strong>
<%
strTemp = WI.fillTextValue("emp_id");
if (dbOP.strBarcodeID != null) 
	strTemp = dbOP.strBarcodeID;
strTemp = strTemp.toUpperCase();
%>			
			<%=strTemp%></strong></font></td>
          </tr>
          <tr> 
            <%
	if (vEmployeeRecords != null)
		strTemp =WI.formatName((String)vEmployeeRecords.elementAt(1),(String)vEmployeeRecords.elementAt(2),
								(String)vEmployeeRecords.elementAt(3),4) ;
	else
		strTemp = "";
%>
            <td height="25"><font color="#FFFFFF">Name : </font><font color="#FFFFFF" size="3"><strong> 
              </strong></font></td>
            <td height="25"><font color="#FFFFFF" size="3"><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></font></td>
          </tr>
          <tr> 
<%	if (vEmployeeRecords != null) strTemp =WI.getStrValue(vEmployeeRecords.elementAt(15));
		else strTemp = "";%>
		
            <td height="25"><font color="#FFFFFF">Job Title : </font><font color="#FFFFFF" size="3">&nbsp;</font></td>
            <td height="25"><font color="#FFFFFF" size="3"><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></font></td>
          </tr>
          <tr> 
            <%
		if (vEmployeeRecords != null){
			if(vEmployeeRecords.elementAt(13) == null)
				strTemp = WI.getStrValue(vEmployeeRecords.elementAt(14));
			else
			{	
				strTemp =WI.getStrValue(vEmployeeRecords.elementAt(13));
				if(vEmployeeRecords.elementAt(14) != null)
					strTemp += WI.getStrValue((String)vEmployeeRecords.elementAt(14), "/" ,"","");
			}
		}
		else
			strTemp = "";
%>
            <td height="25"><font color="#FFFFFF">Office/Dept : </font></td>
            <td height="25"><font color="#FFFFFF" size="3"><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></font></td>
          </tr>
<!--
          <tr> 
            <td height="25"><font color="#FFFFFF">Total Late : </font></td>
<%
	if (vEmployeeRecords != null)
//		strTemp = tinEmployee.getTotalLateTimeInMOnth(dbOP,(String)vEmployeeRecords.elementAt(0));
%>
            <td height="25"><font color="#FFFFFF" size="3"><strong><%=WI.getStrValue(strTemp,"&nbsp;")%></strong></font></td>
          </tr>		  
-->
          <tr> 
            <td height="25" colspan="2" align="center"><strong><font color="#FFFFFF" size="3">EMP. 
              ID # :  
              <input name="emp_id"  type="text" size="16" class="textbox"  
	  style="font-size:25;color='red';" onFocus="style.backgroundColor='#D3EBFF'" 
	  onBlur="style.backgroundColor='white'" OnKeyUP="javascript:this.value=this.value.toUpperCase();PageSubmit(event, '1');">
	  
	  <%if(strDTRAllowStat.equals("2")) {%>
	  	&nbsp;&nbsp;&nbsp;
		PASSWORD: <input name="pswd_"  type="password" size="16" class="textbox"  
	  style="font-size:25;color='red';" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" OnKeyUP="PageSubmit(event, '2');">	  
	  <%}%>
	  
              </font></strong> </td>
          </tr>
        </table>
        <div align="center"><font size=3 color="#FFFF80"><strong> </strong></font></div></td>
      <td width="25%" valign="top"> <table width="100%" border="0" cellpadding="0" cellspacing="1" bgcolor="#D2E1D1" >
          <tr bgcolor="#336699"> 
            <td width="48%" ><div align="center"><strong><font color="#FFFFFF">EMPLOYEE 
                ID </font></strong></div></td>
            <td width="52%" height="20"><strong><font color="#FFFFFF">MM-DD ::</font></strong><font color="#FFFFFF"><strong>TIME</strong></font></td>
          </tr>
          <%	
	if(false)
		vTimeInList = tinEmployee.getLastTimeInTimeOutList(dbOP, false);
	if (vTimeInList!=null) {
	 	for (i= 0; i<vTimeInList.size() ; i+=3){
			if (i == 0){ %>
          <tr bgcolor="#75B3AF"> 
            <td height="18"><b><%=(String)vTimeInList.elementAt(i+2)%></b></td>
            <td height="18"><b><%=(String)vTimeInList.elementAt(i)%></b></td>
            <%}else{%>
          <tr> 
            <td height="18"><%=(String)vTimeInList.elementAt(i+2)%></td>
            <td height="18"><%=(String)vTimeInList.elementAt(i)%></td>
            <%}%>
          </tr>
          <%		} 
	}
%>
        </table>
        <div align="center"><br>
          <font color="#FF0000" size="7" face="Verdana, Arial, Helvetica, sans-serif"><strong> 
          <%
 if ((strTimeInTimeOutLabel!=null) && (strTimeInTimeOutLabel.trim().length() > 1)
 		&& (strTimeInTimeOutLabel.compareTo("Time Out")==0)){
%>
          <%=strTimeInTimeOutLabel%> 
          <%}%>
          &nbsp;</strong></font> </div></td>
    </tr>
  </table>
  <table width="100%" border="0" cellspacing="0" cellpadding="0">
      <tr> 
      <td width="32%" valign="top"><div align="center"> 
          <input type=text name="dispClk" size="12"  readonly="yes"
			style="border: 0;Color='#FFFF80';
			 font-size:72;background-color: #6666B3;font-family: Verdana, Geneva, Arial, Helvetica, sans-serif;">
          <!--<input name="image" type="image" onClick="AddRecord();" src="../../images/hidden_btn.gif">-->
        </div></td>
      <td width="68%" colspan="2" valign="top"><div align="center"><font size=3 color="#FFFF80"><strong>&nbsp; 
          <%
//get birthbay message here.
MessageSystem msgSys = new MessageSystem();
 
strTemp =  WI.fillTextValue("emp_id");
if (dbOP.strBarcodeID != null) 
	strTemp = dbOP.strBarcodeID;
 
strTemp = msgSys.getBirthDayMsg(dbOP, strTemp,0,true);
if(strTemp != null && strTemp.length() > 0) {
	if(strErrMsg != null && strErrMsg.length() > 0) 
		strErrMsg = "<font size=5>"+strTemp + "</font><br>"+strErrMsg;
	else
		strErrMsg = "<font size=5>"+strTemp+ "</font>";
}%>
          <%=WI.getStrValue(strErrMsg,"")%></strong></font></div></td>
    </tr>
<%
//get here eDTR message.. 
	if(strUserIndex != null)
		strTemp = msgSys.getSystemMsg(dbOP, strUserIndex, 12);
	else	
		strTemp = null;
	if(strTemp != null){%>
     <tr>
        <td colspan="3" valign="top">
			  <table width="100%" cellpadding="0" cellspacing="0">
				<tr>
				  <td width="2%" height="25">&nbsp;</td>
				  <td width="96%" style="font-size:17px; color:#FFFF00; background-color:#7777aa;" class="thinborderALL"><%=strTemp%></td>
				  <td width="2%">&nbsp;</td>
				</tr>
			 </table>
		</td>
      </tr>
	<%}%>
</table>
  <input type="hidden" name="addRecord">
<input type="hidden" name="strIndex" value="">
</form>
</body>
</html>
<% 	
dbOP.cleanUP(); 
%>
