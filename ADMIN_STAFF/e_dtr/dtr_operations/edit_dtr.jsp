<%@ page language="java" import="utility.*,java.util.Vector,eDTR.TimeInTimeOut" %>
<%
///added code for HR/companies.
boolean bolIsSchool = false;
if( (new ReadPropertyFile().getImageFileExtn("IS_SCHOOL","1")).equals("1"))
	bolIsSchool = true;
%>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Update Time In/Out Records</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript">
<!--
	function ViewRecords(){
		document.dtr_op.iAction.value = 4;
		document.dtr_op.prepareToEdit.value = 0;
	}
	
	function PrepareToEdit(index,bTimeInTimeOut,strDate){
 		document.dtr_op.prepareToEdit.value = 1;
		document.dtr_op.bTimeIn.value= bTimeInTimeOut;
		document.dtr_op.info_index.value = index;
		document.dtr_op.requested_date.value = strDate;
	}
	
	function AddRecord(){
		document.dtr_op.iAction.value = 1;
	}
	
	function EditRecord(){
		document.dtr_op.iAction.value = 2;
		document.dtr_op.bTimeIn.value = document.dtr_op.strStatus1.value;
	}
	
	function CancelEdit(){
		location = "./edit_dtr.jsp?emp_id="+document.dtr_op.emp_id.value+"&requested_date="+document.dtr_op.requested_date.value;
	}

	function DeleteRecord(index,logged){
		document.dtr_op.iAction.value = 0;
		document.dtr_op.info_index.value = index;
		document.dtr_op.info_logged.value = logged;
		document.dtr_op.submit();
	}

	function ClearDate(){
	 document.dtr_op.requested_date.value = "";
	 //document.dtr_op.submit();
	}

	function updateWH(strIndex){
	var loadPg = "./wh_update.jsp?emp_id=" + strIndex;
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
	}
	function focusID() {
		document.dtr_op.emp_id.focus();
	}
	
	function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=dtr_op.emp_id";
	var win=window.open(pgLoc,"SearchWindow",'width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
-->
</script>
<body bgcolor="#D2AE72" onLoad="focusID();">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
//add security here.

try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Edit Time-in Time-out","edit_dtr.jsp");

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
		<p align="center"> <font face="Verdana, Arial, Helvetica, sans-serif" size="3"><%=strErrMsg%></font></p>
		<%
		return;
	}

//authenticate this user.
CommonUtil comUtil = new CommonUtil();
int iAccessLevel = comUtil.isUserAuthorizedForURL(dbOP,(String)request.getSession(false).getAttribute("userId"),
														"eDaily Time Record","DTR OPERATIONS",request.getRemoteAddr(),
														"edit_dtr.jsp");
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

TimeInTimeOut TInTOut = new TimeInTimeOut();
Vector vTimeInList = null;
Vector vPersonalDetails = null;
Vector vRetResult = null;
Vector vEditResult = null;
String strPrepareToEdit = null;

strPrepareToEdit = WI.fillTextValue("prepareToEdit");

if (WI.fillTextValue("iAction").compareTo("1") == 0){
	vTimeInList = TInTOut.operateOnTimeInTimeOut(dbOP,request,1);

	if (vTimeInList !=null && vTimeInList.size() > 0){
		strErrMsg = " Time Record added successfully";
	}else{
		strErrMsg= TInTOut.getErrMsg();
	}
}else if(WI.fillTextValue("iAction").equals("2")){
	vTimeInList = TInTOut.operateOnTimeInTimeOut(dbOP,request,2);

	if (vTimeInList !=null && vTimeInList.size() > 0){
		strErrMsg = " Time Record edited successfully";
		strPrepareToEdit = "0";
	}else{
		strErrMsg= TInTOut.getErrMsg();
	}
}else if (WI.fillTextValue("iAction").equals("0")){
	vTimeInList = TInTOut.operateOnTimeInTimeOut(dbOP,request,0);

	if (vTimeInList !=null && vTimeInList.size() > 0){
		strErrMsg = " Time Record deleted successfully";
	}else{
		strErrMsg= TInTOut.getErrMsg();
	}
}

if(strPrepareToEdit.equals("1")){
	vEditResult = TInTOut.getTimeInTimeOutDetails(dbOP,request);
	
	if (vEditResult == null)
		strErrMsg = TInTOut.getErrMsg();
}

%>

<form action="./edit_dtr.jsp" method="post" name="dtr_op">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A">
      <td width="100%" height="25"><div align="center"><font color="#FFFFFF" ><strong>::::
          DTR OPERATIONS - EDIT TIME-IN TIME-OUT PAGE ::::</strong></font></div></td>
    </tr>
    <tr >
      <td height="25">&nbsp; <font size="3" color="#FF0000"><b><%=WI.getStrValue(strErrMsg)%></b></font></td>
    </tr>
  </table>
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="23">&nbsp;</td>
      <td height="23">Employee ID </td>
      <td width="23%" height="23"> <input type="text" name="emp_id" value="<%=WI.fillTextValue("emp_id")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'">
        &nbsp; </td>
      <td width="15%"><a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a></td>
      <td width="47%" rowspan="3" valign="top"> <% if (WI.fillTextValue("emp_id").length() > 0) {
    enrollment.Authentication authentication = new enrollment.Authentication();
    vPersonalDetails = authentication.operateOnBasicInfo(dbOP,request,"0");
	if (vPersonalDetails!=null){
%> <table width="100%" border="1" cellpadding="0" cellspacing="0" bordercolor="#000000">
          <tr> 
            <td> <table width="100%" border="0" cellspacing="0" cellpadding="3">
                <tr> 
                  <td width="27%" rowspan="4"> <%strTemp = "<img src=\"../../../upload_img/"+WI.fillTextValue("emp_id").toUpperCase()+"."+strImgFileExt+"\" width=100 height=100 border=1>";
%> <%=strTemp%> </td>
                  <% strTemp = WI.formatName((String)vPersonalDetails.elementAt(1), (String)vPersonalDetails.elementAt(2),
							(String)vPersonalDetails.elementAt(3), 4);
%>
                  <td width="73%" height="25"><strong><font size=1>Name : <%=WI.getStrValue(strTemp)%></font></strong></td>
                </tr>
                <tr> 
                  <td height="25"><strong><font size=1>Position: <%=WI.getStrValue((String)vPersonalDetails.elementAt(15))%></font></strong></td>
                </tr>
                <%
	 if((String)vPersonalDetails.elementAt(13) == null)
		strTemp = WI.getStrValue((String)vPersonalDetails.elementAt(14));
	else
		{
		strTemp =WI.getStrValue((String)vPersonalDetails.elementAt(13));
		if((String)vPersonalDetails.elementAt(14) != null)
		 strTemp += "/" + WI.getStrValue((String)vPersonalDetails.elementAt(14));
		}
%>
                <tr> 
                  <td height="25"><strong><font size=1>Office/<%if(bolIsSchool){%>College<%}else{%>Division<%}%> : <%=WI.getStrValue(strTemp)%></font></strong></td>
                </tr>
                <tr> 
                  <td height="25"><strong><font size=1>Status: <%=WI.getStrValue((String)vPersonalDetails.elementAt(16))%></font></strong></td>
                </tr>
              </table></td>
          </tr>
        </table>
        <%}else{%> <font size=2><strong><%=authentication.getErrMsg()%></strong></font> <%}}%> </td>
    </tr>
    <tr> 
      <td height="20">&nbsp;</td>
      <td height="20">Date </td>
      <td height="20" colspan="2"> <%
strTemp = WI.fillTextValue("requested_date");

if (strPrepareToEdit.equals("1") && vEditResult != null) {
	strTemp = (String)vEditResult.elementAt(4);
}
if(strTemp.length() == 0)
	strTemp = WI.getTodaysDate(1);
%> <input name="requested_date" type="text" size="12" maxlength="12" value="<%=strTemp%>" class="textbox"
	                    onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"> 
        <a href="javascript:show_calendar('dtr_op.requested_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a>&nbsp;&nbsp;<a href="javascript:ClearDate();"><img src="../../../images/clear.gif" width="55" height="19" border="0" ></a><font size="1"> 
        clear the date</font></td>
    </tr>
    <tr> 
      <td width="3%" height="35">&nbsp;</td>
      <td width="12%" height="25">&nbsp;</td>
      <td colspan="2"><input name="image" type="image" onClick="ViewRecords()"  src="../../../images/form_proceed.gif" width="81" height="21" border="0"></td>
    </tr>
  </table>
 <% if (vPersonalDetails!=null && WI.fillTextValue("emp_id").length() > 0){ %>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25" colspan="4"><hr size="1"></td>
    </tr>

    <%

if (strPrepareToEdit.equals("1") && vEditResult != null){
	strTemp =WI.getStrValue((String)vEditResult.elementAt(1));
	if (strTemp.compareTo("00") == 0) strTemp="12";


%><tr>
      <td height="25">&nbsp;</td>
      <td>WORKING HOUR</td>
      <td><input name="wh_index" type="text" size="4" maxlength="4" readonly value="<%=WI.getStrValue((String)vEditResult.elementAt(5),"")%>" class="textbox_noborder">
        &nbsp;</td>
      <td>
<%  if (WI.fillTextValue("bTimeIn").equals("0")){ %>
	  <a href='javascript:updateWH("<%=request.getParameter("emp_id")%>");'><img src="../../../images/update.gif" alt="update working hour" width="60" height="26" border="0"></a><font size="1">click
        to update working hour</font>
<%}%>
		&nbsp;</td>
    </tr>
    <tr>
      <td width="15%" height="25">&nbsp;</td>
      <td width="18%">NEW TIME</td>
      <td width="21%"> <input name="hh" type="text" size="2" maxlength="2" value="<%=strTemp%>" class="textbox"
	   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('dtr_op','hh')"
	    onKeyUp="AllowOnlyInteger('dtr_op','hh')">
        :
        <input name="mm" type="text" size="2" maxlength="2" value="<%=WI.getStrValue((String)vEditResult.elementAt(2))%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyInteger('dtr_op','mm')"
	  onKeyUp="AllowOnlyInteger('dtr_op','mm')">
        <select name="am_pm">
          <option value="0" >A.M.</option>
          <%	if (((String)vEditResult.elementAt(3)).compareTo("PM") == 0){ %>
          <option value="1" selected>P.M.</option>
          <%}else{%>
          <option value="1">P.M.</option>
          <%}%>
        </select> </td>
      <td width="46%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td> STATUS </td>
      <td> 
<% 

	if (WI.fillTextValue("bTimeIn").equals("0")){
		strTemp = "TIME IN";
	}else{
		strTemp = "TIME OUT";
	}
%> <strong><%=strTemp%></strong> <input name="strStatus1" type="hidden" value="<%=WI.fillTextValue("bTimeIn")%>" size="12" maxlength="12" readonly>
      </td>
      <td>&nbsp;</td>
    </tr>
    <%}else{%>
    <tr>
      <td width="15%" height="25">&nbsp;</td>
      <td width="18%">NEW TIME</td>
      <td width="21%"> <input name="hh" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("hh")%>" class="textbox"
	   onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        :
        <input name="mm" type="text" size="2" maxlength="2" value="<%=WI.fillTextValue("mm")%>" class="textbox"
	  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	  onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;">
        <select name="am_pm">
          <option value="0" >A.M.</option>
          <%	if (WI.fillTextValue("bTimeIn").compareTo("PM") == 0){ %>
          <option value="1" selected>P.M.</option>
          <%}else{%>
          <option value="1">P.M.</option>
          <%}%>
        </select> </td>
      <td width="46%">&nbsp;</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td>NEW STATUS </td>
      <td><select name="strStatus2">
          <option value="0"> Time-In</option>
          <% if (WI.fillTextValue("bTimeIn").equals("1")) {%>
          <option value="1" selected> Time-Out</option>
          <% }else{ %>
          <option value="1">Time-Out</option>
          <% } %>
        </select> </td>
      <td>&nbsp;</td>
    </tr>
    <%}%>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3">REASON :</td>
    </tr>
    <tr>
      <td height="25">&nbsp;</td>
      <td colspan="3" valign="top"><textarea name="txtReason" cols="48" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"></textarea>
      </td>
    </tr>
    <tr>
      <td height="25" colspan="4"> <div align="center">
          <%
 	strTemp = strPrepareToEdit;
    if(WI.getStrValue(strTemp,"0").compareTo("0") == 0) {
		if (iAccessLevel > 1){
%>
          <input type="image" src="../../../images/add.gif" width="42" height="32"
		  onClick="AddRecord()">
          <font size="1">click to add record </font>
          <%     }
  }else{ %>
          <input type="image" src="../../../images/edit.gif" border="0" onClick='EditRecord()'></a>
          <font size="1">click to save changes</font> <a href='javascript:CancelEdit();'><img src="../../../images/cancel.gif" border="0"></a>
          <font size="1">click to cancel or go previous</font>
          <%}%>
        </div></td>
    </tr>
    <tr>
      <td height="15" colspan="4">&nbsp; </td>
    </tr>

  </table>
  <%
	if ((vTimeInList != null) && (vTimeInList.size()>0)) { %>

  <table width="100%" border="0" cellpadding="0" cellspacing="0"  
  			bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="5" class="thinborder"><div align="center"><font color="#FFFFFF">
	  	<strong>LIST OF TIME RECORDED</strong></font></div></td>
    </tr>
    <tr >
      <td width="27%" height="25" class="thinborder"><div align="center"><strong>DAY :: TIME</strong></div></td>
      <td width="31%" class="thinborder"><div align="center"><strong>STATUS</strong></div></td>
      <td width="20%" class="thinborder"><div align="center"><strong>LATE / UNDERTIME</strong></div></td>
      <td width="22%" height="25" class="thinborder"><div align="center"><strong>EDIT / DELETE</strong></div></td>
    </tr>
    <%  for (int i=0; i < vTimeInList.size() ; i+=9){ %>
    <tr >
      <td height="25"  class="thinborder"><div align="center"><%=(String)vTimeInList.elementAt(i)%></div></td>
      <td  class="thinborder"><div align="center">TIME IN</div></td>
	  <% strTemp = WI.getStrValue((String)vTimeInList.elementAt(i+5));
	  	if (strTemp.length() == 0 || strTemp.equals("0"))   
			strTemp = "";
		else
			strTemp  += " min(s)"; %>
      <td  class="thinborder">&nbsp;<%=strTemp%></td>
      <td  class="thinborder"><div align="center">
          <% if (iAccessLevel > 1){ %>
          <input type="image" src="../../../images/edit.gif" width="40" height="26"
					onClick='PrepareToEdit("<%=(String)vTimeInList.elementAt(i+4)%>","0")'>
          <% if (iAccessLevel == 2){ %>
          <a href='javascript:DeleteRecord("<%=(String)vTimeInList.elementAt(i+4)%>","0");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
          <%}}%>
          &nbsp;</div></td>
    </tr>
	<% if ((String)vTimeInList.elementAt(i+1) !=null ) {%>
    <tr>
      <td  class="thinborder"><div align="center"><%=(String)vTimeInList.elementAt(i+1)%></div></td>
      <td  class="thinborder"><div align="center">TIME OUT</div></td>
      <td  class="thinborder">&nbsp;<%=WI.getStrValue((String)vTimeInList.elementAt(i+6),
	  													""," min(s)","")%></td>
      <td height="25"  class="thinborder"><div align="center">
          <% if (iAccessLevel > 1){ %>
          <input type="image" src="../../../images/edit.gif" width="40" height="26"
					onClick='PrepareToEdit("<%=(String)vTimeInList.elementAt(i+4)%>","1")'>
          <% if (iAccessLevel == 2){ %>
          <a href='javascript:DeleteRecord ("<%=(String)vTimeInList.elementAt(i+4)%>","1");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
          <%}}%>
          &nbsp; </div></td>
    </tr>
    <%} // end ((String)vTimeInList.elementAt(i+1) == null)
 } //end for loop

%>
  </table>
<%}} // end else (vTimeInList == null)%>
  
  <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="prepareToEdit" value="0">
<input type="hidden" name="iAction" value="">
<input type="hidden" name="bTimeIn" value="">
<input type="hidden" name="info_index" value="<%= request.getParameter("info_index")%>">
<input type="hidden" name="info_logged">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>
