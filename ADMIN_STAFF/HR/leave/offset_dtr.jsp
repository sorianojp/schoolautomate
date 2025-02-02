<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLeave" %>
<%
	///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;

	String[] strColorScheme = CommonUtil.getColorScheme(5);
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>eDTR Manual Entry</title>
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
<style type="text/css">
	.txtbox_noborder {
		font-family:Verdana, Arial, Helvetica, sans-serif;
		text-align:right;
		border: 0; 
	}
</style>

</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>
<script language="JavaScript">
	function ViewRecords(){
		document.dtr_op.iAction.value = 4;
	}

	function UpdateRecord(){
		document.dtr_op.iAction.value = 1;
		document.dtr_op.submit();
	}

</script>
<body bgcolor="#D2AE72"class="bgDynamic">
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	String strSchCode =  WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));

try	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Edit Time-in Time-out","offset_dtr.jsp");

		ReadPropertyFile readPropFile = new ReadPropertyFile();
		strImgFileExt = readPropFile.getImageFileExtn("imgFileUploadExt");

		if(strImgFileExt == null || strImgFileExt.trim().length() ==0)
		{
			strErrMsg = "Image file extension is missing. Please contact school admin.";
			dbOP.cleanUP();
			throw new Exception();
		}
	}catch(Exception exp)	{
		exp.printStackTrace();
		if(strErrMsg == null)
			strErrMsg = "Error in opening DB Connection.";
		%>
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}
//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(),
														"offset_dtr.jsp");
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

//end of authenticaion code.

///// exclusive for testers only.. 
String strUserID = (String)request.getSession(false).getAttribute("userId");
//////////////////



HRInfoLeave TInTOut = new HRInfoLeave();
Vector vTimeInList = null;
Vector vPersonalDetails = null;
Vector vRetResult =  null;
 String strLateUnderTime = null;
String[] astrExcuse = {"Unexcused", "Excused"};
int iPageAction  = 0;
strTemp = WI.fillTextValue("iAction");
iPageAction = Integer.parseInt(WI.getStrValue(strTemp,"4"));
//	System.out.println("1- " + ConversionTable.compareDate("9/11/2009", "9/12/2009"));
//	System.out.println("2- " + ConversionTable.compareDate("9/11/2009", "9/11/2009"));
//	System.out.println("3- " + ConversionTable.compareDate("9/12/2009", "9/11/2009"));
if (iPageAction == 1 || iPageAction == 4){
  switch (iPageAction){
	case 1:
			if (TInTOut.operateOnDtrLeaveOffsetting(dbOP, request, iPageAction, WI.fillTextValue("leave_info_index")) == null)
				strErrMsg = TInTOut.getErrMsg();
			else{
				strErrMsg = " Record updated successfully";
			}
			break;
	} // end switch
}


	if (WI.fillTextValue("leave_info_index").length() > 0)
		vTimeInList = TInTOut.operateOnDtrLeaveOffsetting(dbOP, request,4, WI.fillTextValue("leave_info_index"));
	
	if (vTimeInList == null || vTimeInList.size() == 2){
		if(strErrMsg == null || strErrMsg.length() == 0)
			strErrMsg  = TInTOut.getErrMsg();
	}	
%>
<form action="./offset_dtr.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
        PROCESS LATE/UNDERTIME PAGE ::::</strong></font></td>
    </tr>
    <tr >
      <td height="25">&nbsp; <strong><%=WI.getStrValue(strErrMsg,"")%></strong></td>
    </tr>
  </table>
  <%if (vTimeInList != null && vTimeInList.size() > 2){%>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr>
			<%
				strTemp = (String)vTimeInList.elementAt(0);
				strTemp = CommonUtil.formatFloat(strTemp, false);
				strTemp = ConversionTable.replaceString(strTemp, ",","");
			%>
      <td height="25" colspan="6" class="thinborder"> Leave for adjustment : <%=strTemp%>
			<input type="hidden" value="<%=strTemp%>" 
			 name="total_leave" style="text-align:left">			</td>
    </tr>
    <tr bgcolor="#B9B292">
      <td height="25" colspan="6" align="center" class="thinborder"><font color="#FFFFFF">
	  	<strong>LIST OF TIME RECORDED</strong></font></td>
    </tr>
    <tr >
      <td width="22%" height="25" align="center" class="thinborder"><strong>DAY :: TIME</strong></td>
      <td width="19%" align="center" class="thinborder"><strong>STATUS</strong></td>
      <td width="18%" align="center" class="thinborder"><strong>LATE / UNDERTIME</strong></td>
       <td width="28%" align="center" class="thinborder"><strong>EXCUSED / UNEXCUSED</strong> </td>
      <td width="5%" height="25" align="center" class="thinborder"><strong>EDIT </strong></td>
    </tr>
    <%  
		int iCtr = 0;
 		for (int i=2; i < vTimeInList.size() ; i+=16,iCtr++){
		%>
	  	<input type="hidden" value="<%=vTimeInList.elementAt(i+4)%>"
			name="tin_tout_index_<%=iCtr%>">		

		<% 
		strTemp = WI.getStrValue((String)vTimeInList.elementAt(i+5));
		if (strTemp.length() > 0 && !strTemp.equals("0")){
		%>	  
    <tr >
      <td height="25"  class="thinborder">&nbsp;<%=(String)vTimeInList.elementAt(i)%></td>
      <td  class="thinborder">&nbsp;TIME IN</td>
		  <td  class="thinborder">&nbsp;
	  	<input type="text" class="txtbox_noborder" value="<%=strTemp%>" size="3"
			maxlength="3"  readonly	name="late_val_<%=iCtr%>">
			<%if (strTemp.length() != 0 && !strTemp.equals("0")){%>	min(s) <%}%>			</td>
    	<td  class="thinborder">&nbsp;
	  	<%if (strTemp.length() != 0) {%> 
	  		<%=astrExcuse[Integer.parseInt(WI.getStrValue((String)vTimeInList.elementAt(i+7),"0"))]%>
	  		<%=WI.getStrValue((String)vTimeInList.elementAt(i+9),"(",")","")%>
			<%}%>			</td>
      <td align="center"  class="thinborder"><input type="checkbox" value="1" name="late_<%=iCtr%>"></td>
    </tr>
		<%}%>
		<% if((String)vTimeInList.elementAt(i+1) != null ){%>
		<%	strTemp = WI.getStrValue((String)vTimeInList.elementAt(i+6));
		if (strTemp.length() > 0 && !strTemp.equals("0")){
		%>
    <tr>
      <td  class="thinborder">&nbsp;<%=(String)vTimeInList.elementAt(i+1)%></td>
      <td  class="thinborder">&nbsp;TIME OUT</td>
      <td  class="thinborder">&nbsp;
	  	<input type="text" class="txtbox_noborder" value="<%=strTemp%>" size="3"
			maxlength="3" readonly name="ut_val_<%=iCtr%>">		
				<%if (strTemp.length() != 0 && !strTemp.equals("0")){%>	min(s) <%}%>	 </td>
      <td  class="thinborder">&nbsp;
	  <%if ((String)vTimeInList.elementAt(i+6) != null) {%> 
	      <%=astrExcuse[Integer.parseInt(WI.getStrValue((String)vTimeInList.elementAt(i+8),"0"))]%>
	      <%=WI.getStrValue((String)vTimeInList.elementAt(i+10),"(",")","")%>
	  <%}%></td>
      <td height="25" align="center"  class="thinborder"><input type="checkbox" value="1" name="ut_<%=iCtr%>"></td>
    </tr>
		<%}%>
    <%}		
	 } //end for loop%>
	 <input type="hidden" name="row_count" value="<%=iCtr%>">
    <tr>
      <td height="25" colspan="5" align="center"  class="thinborder">&nbsp;</td>
    </tr>
    <tr>
      <td height="25" colspan="5" align="center"  class="thinborder"><a href="javascript:UpdateRecord();"><img src="../../../images/update.gif" name="hide_save" width="60" height="26" border="0"></a></td>
    </tr> 
  </table>
<%} // end else (vTimeInList == null)%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>

	<input type="hidden" name="iAction" value="">
	<input type="hidden" name="leave_info_index" value="<%=WI.fillTextValue("leave_info_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>