<%@ page language="java" import="utility.*,java.util.Vector,eDTR.eDTRSettings" %>
<%
String[] strColorScheme = CommonUtil.getColorScheme(7);
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
<!--
	function ViewRecords(){
		document.dtr_op.page_action.value = 4;
		document.dtr_op.prepareToEdit.value = 0;
		document.dtr_op.show_list.value = 1;		
	}
	function viewAll()
	{
		document.dtr_op.page_action.value = 4;		
		this.SubmitOnce('dtr_op');
	}

	function PrepareToEdit(index){
 		document.dtr_op.prepareToEdit.value = 1;
		document.dtr_op.info_index.value = index;
		document.dtr_op.submit();
	}

	function AddRecord(){
		document.dtr_op.page_action.value = 1;
		this.SubmitOnce("dtr_op");
	}

	function EditRecord(){
		document.dtr_op.page_action.value = 2;
		this.SubmitOnce("dtr_op");
	}

	function CancelEdit(){
		location = "./class_suspension.jsp?suspension_date="+document.dtr_op.suspension_date.value;
	}

	function DeleteRecord(index,strAMPM){
		document.dtr_op.page_action.value = "0";
		document.dtr_op.info_index.value = index;
		document.dtr_op.submit();
	}

function UpdateTime(strInfoIndex){
	var vHour = document.dtr_op.suspend_hr.value;
	var vMin =  document.dtr_op.suspend_min.value;
	var vAmPm = document.dtr_op.suspend_ampm.value;
	var vTime = 12;	
			//if(iHour >= 12){
							//	if(iHour > 12)							
							//		iHour = iHour - 12;
							//	strTemp2 = iHour + " PM";
							//}
	
	vTime = eval(vHour) + eval(vMin/60);
	if(vAmPm == 1){
		if(vHour < 12)
			vTime += 12;
	}else{
		if(vHour == 12)
			vTime -= 12;
	}

 	document.dtr_op.RESTRICTED_TIME.value = vTime;
}
-->
</script>
<body bgcolor="#D2AE72" class="bgDynamic">
<%

	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	String strErrMsg = "";
	String strTemp = null;
	String strTemp2 = null;
	boolean bolProceed = true;
	String strImgFileExt = null;
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
//add security here.
try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-eDaily Time Record-Edit Time-in Time-out","class_suspension.jsp");

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
														"class_suspension.jsp");
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



eDTRSettings suspend = new eDTRSettings();
Vector vRetResult = null;
Vector vPersonalDetails = null;
Vector vEditInfo =  null;
String strPrepareToEdit = WI.fillTextValue("prepareToEdit");
String strLateUnderTime = null;
String[] astrExcuse = {"Unexcused", "Excused"};
int iPageAction  = 0;

String strTime = null;
int iHour = 0;
int iMinute = 0;
double dTime = 0d;
String strAMPM = null;

strTemp = WI.fillTextValue("page_action");
iPageAction = Integer.parseInt(WI.getStrValue(strTemp,"4"));
//	System.out.println("1- " + ConversionTable.compareDate("9/11/2009", "9/12/2009"));
//	System.out.println("2- " + ConversionTable.compareDate("9/11/2009", "9/11/2009"));
//	System.out.println("3- " + ConversionTable.compareDate("9/12/2009", "9/11/2009"));
if (iPageAction == 0 || iPageAction == 1 || iPageAction == 2 || iPageAction == 5){
  switch (iPageAction){
	case 0:
			if (suspend.operateOnClassSuspension(dbOP,request,iPageAction) == null)
				strErrMsg = suspend.getErrMsg();
			else
				strErrMsg = " Record deleted successfully";
			break;
	case 1:
			if (suspend.operateOnClassSuspension(dbOP,request,iPageAction) == null)
				strErrMsg = suspend.getErrMsg();
			else{
				strErrMsg = " Record added successfully";
			}
			break;
	case 2:
			if (suspend.operateOnClassSuspension(dbOP,request,iPageAction) == null)
				strErrMsg = suspend.getErrMsg();
			else{
				strErrMsg = " Record edited successfully";
				strPrepareToEdit = "0";
			}
			break;
	} // end switch
}


if(strPrepareToEdit.equals("1")){
	vEditInfo = suspend.operateOnClassSuspension(dbOP, request, 3);
}


	vRetResult = suspend.operateOnClassSuspension(dbOP, request,4);
	
	if (vRetResult == null || vRetResult.size() == 0){
		if(strErrMsg == null || strErrMsg.length() == 0)
			strErrMsg  = suspend.getErrMsg();
	}	

%>
<form action="./class_suspension.jsp" method="post" name="dtr_op">
    <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
      <tr bgcolor="#A49A6A">
        <td width="100%" height="25" align="center" class="footerDynamic"><font color="#FFFFFF" ><strong>::::
          DTR OPERATIONS - CLASSES SUSPENSION PAGE ::::</strong></font></td>
      </tr>
      <tr >
        <td height="25">&nbsp; <strong><%=WI.getStrValue(strErrMsg,"")%></strong></td>
      </tr>
    </table>

  <table width="100%" border="0" cellspacing="0" cellpadding="0" bgcolor="#FFFFFF">
 		<tr>
		  <td>&nbsp;</td>
		  <td>Date</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(1);
				else
					strTemp = WI.fillTextValue("suspension_date");
					
				if(strTemp.length() == 0)
					strTemp= WI.getTodaysDate(1);
			%>
		  <td><input name="suspension_date" type="text" size="12" maxlength="12" value="<%=strTemp%>"
	    onfocus="style.backgroundColor='#D3EBFF'" class="textbox" 
			onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('dtr_op','suspension_date','/');"
			onKeyUp = "AllowOnlyIntegerExtn('dtr_op','suspension_date','/')">
        <a href="javascript:show_calendar('dtr_op.suspension_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" border="0"></a></td>
	  </tr>
		<tr>
      <td width="4%">&nbsp;</td>
      <td width="15%">College</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(4);
				else
					strTemp = WI.fillTextValue("c_index");				
			%>
      <td width="81%">
			<select name="c_index">
        <option value="">ALL</option>
        <%=dbOP.loadCombo("c_index","c_name", " from college where is_del= 0", strTemp,false)%>
      </select>			</td>
    </tr>
		<tr>
		  <td height="22">&nbsp;</td>
		  <td>Cut - Off</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTime = (String)vEditInfo.elementAt(2);
				else
					strTime = WI.fillTextValue("suspend_hr");
					
 				strTime = WI.getStrValue(strTime,"13");			
				
				dTime = Double.parseDouble(strTime);
					if(dTime >= 12){
						strAMPM = "1";
						if(dTime > 12)
							dTime = dTime - 12;
					} else {
						strAMPM = "0";
					}
					
					iHour = (int)dTime;
					dTime = ((dTime - iHour) * 60) + .02;
					iMinute = (int)dTime;
					if(iHour == 0)
						iHour = 12;								
					strTemp = Integer.toString(iHour);

					if(strTemp.length() == 0)
						strTemp = "12";				
			%>			
		  <td><select name="suspend_hr" style="font-size:10px;" onChange="UpdateTime();">
        <%				
						for(int i = 1; i <= 12; i++){ 
							if(iHour == i)
								strErrMsg = " selected";
							else	
								strErrMsg = "";	
						%>
        <option value="<%=i%>"<%=strErrMsg%>><%=i%></option>
        <%}%>
      </select>
        <select name="suspend_min" style="font-size:10px;" onChange="UpdateTime();">
          <%
						for(int i = 0; i < 60; i+=5){
							if(iMinute == i)
								strErrMsg = " selected";
							else	
								strErrMsg = "";	
						%>
          <option value="<%=i%>"<%=strErrMsg%>><%=i%></option>
          <%}%>
        </select>
				
        <select name="suspend_ampm" onChange="UpdateTime();">
          <option value="0">AM</option>
          <% if (strAMPM.equals("1")){%>
          <option value="1" selected>PM</option>
          <%}else{%>
          <option value="1">PM</option>
          <%}%>
        </select></td>
	  </tr>
		<tr>
		  <td height="22">&nbsp;</td>
		  <td>Percent credit </td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(3);
				else
					strTemp = WI.fillTextValue("percent_");
 				
 			%>						
		  <td><select name="percent_" style="font-size:10px;">
        <%
						for(int i = 5; i <= 100; i+=5){
							if(strTemp.equals(Integer.toString(i)))
								strErrMsg = " selected";
							else	
								strErrMsg = "";	
						%>
        <option value="<%=i%>"<%=strErrMsg%>><%=i%></option>
        <%}%>
      </select>
		    % of load if first class is before cut-off </td>
	  </tr>
		<tr>
		  <td height="22">&nbsp;</td>
		  <td>&nbsp;</td>
			<%
				if(vEditInfo != null && vEditInfo.size() > 0)
					strTemp = (String)vEditInfo.elementAt(7);
				else
					strTemp = WI.fillTextValue("percent_after");
 				strTemp = WI.getStrValue(strTemp);
 			%>						
		  <td><select name="percent_after" style="font-size:10px;">
        <%
						for(int i = 5; i <= 100; i+=5){
							if(strTemp.equals(Integer.toString(i)))
								strErrMsg = " selected";
							else	
								strErrMsg = "";	
						%>
        <option value="<%=i%>"<%=strErrMsg%>><%=i%></option>
        <%}%>
      </select>
% of load if first class is on or after cut-off </td>
	  </tr>
 	</table>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td width="852%" height="20" colspan="4"><hr size="1"></td>
    </tr> 

    <tr>
      <td height="25" colspan="4"> <div align="center">
    <%
    if(WI.getStrValue(strPrepareToEdit, "0").compareTo("0") == 0) {
		  if (iAccessLevel > 1){
		%>
    <input type="button" name="save_" value=" Save " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
					onClick="javascript:AddRecord();">
    <font size="1">click to add record </font>
     <%} // end iAccessLevel  > 1
	  }else{ %>
					<input type="button" name="edit_" value=" Edit " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
					onClick="javascript:EditRecord();">
          <font size="1">click to save changes</font> 
					<input type="button" name="cancel_" value=" Cancel " style="font-size:11px; height:28px;border: 1px solid #FF0000;" 
					onClick="javascript:CancelEdit();">
          <font size="1">click to cancel or go previous</font>
          <%}%>
        </div></td>
    </tr>
    <tr>
      <td height="20" colspan="4">&nbsp;</td>
    </tr>
  </table>
     
	<%if(vRetResult != null && vRetResult.size() > 0){%>
	<table width="100%" bgcolor="#FFFFFF">
		<tr>
			<%
				strTemp = WI.fillTextValue("view_all");
				if(strTemp.length() > 0)
					strTemp = "checked";
				else
					strTemp = "";
			%>			
		  <td align="right"><input type="checkbox" name="view_all" value="1" <%=strTemp%> onClick="viewAll();">
view all &nbsp;&nbsp;&nbsp;</td>
		
	  </tr>	
	</table>
	
  <table width="100%" border="0" cellpadding="0" cellspacing="0"  
  			bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#B9B292">
      <td height="25" colspan="7" align="center" class="thinborder"><font color="#FFFFFF">
	  	<strong>LIST OF TIME RECORDED </strong></font></td>
    </tr>
    <tr >
      <td width="12%" align="center" class="thinborder"><strong>DATE</strong></td>
      <td width="16%" height="25" align="center" class="thinborder"><strong>CUT-OFF TIME</strong></td>
      <td width="28%" align="center" class="thinborder"><strong>Payment</strong></td>
      <td width="24%" align="center" class="thinborder"><strong>COLLEGE</strong></td>
      <td width="8%" height="25" align="center" class="thinborder"><strong>EDIT </strong></td>
      <td width="12%" align="center" class="thinborder"><strong>DELETE</strong></td>
    </tr>
    <%  
		int iCtr = 0;
		for (int i=0; i < vRetResult.size() ; i+=15,iCtr++){ %>
    <tr >
      <td  class="thinborder">&nbsp;<%=(String)vRetResult.elementAt(i+1)%></td>
			<%
				strAMPM = "AM";
				strTime = (String)vRetResult.elementAt(i+2);
				dTime = Double.parseDouble(strTime);
				if(dTime >= 12){
					strAMPM = "PM";
					if(dTime > 12)
						dTime = dTime - 12;
				} else {
					strAMPM = "AM";
				}
				
				iHour = (int)dTime;
				dTime = ((dTime - iHour) * 60) + .02;
				iMinute = (int)dTime;
				if(iHour == 0)
					iHour = 12;								
				strTemp = iHour + ":" + CommonUtil.formatMinute(Integer.toString(iMinute)) + " " + strAMPM;
			%>
      <td height="25"  class="thinborder">&nbsp;<%=strTemp%></td>
      <td  class="thinborder">before cut off : <%=(String)vRetResult.elementAt(i+3)%>%<br>
        on or after cut-off : <%=(String)vRetResult.elementAt(i+7)%>%</td>
	    <% 
			strTemp = WI.getStrValue((String)vRetResult.elementAt(i+5));
	  	if (strTemp.length() == 0 || strTemp.equals("0"))   
				strTemp = ""; %>	  
		  <td  class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+6), "ALL")%> </td>
      <td align="center"  class="thinborder">
			<% if (iAccessLevel > 1){ %>
				<a href='javascript:PrepareToEdit("<%=vRetResult.elementAt(i)%>")'>
				<img src="../../../images/edit.gif" width="40" height="26" border="0">				</a>					
			<%}%></td>
      <td align="center"  class="thinborder">&nbsp;<% if (iAccessLevel == 2){ %>
          <a href='javascript:DeleteRecord("<%=(String)vRetResult.elementAt(i)%>","0");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a>
          <%}%></td>
    </tr>
	<% if ((String)vRetResult.elementAt(i+1) !=null ) {%>
    
    <%} // end ((String)vRetResult.elementAt(i+1) == null)
 } //end for loop%>
  </table>
	 <%}%>
   <table bgcolor="#FFFFFF" width="100%" border="0" cellpadding="0" cellspacing="0">
    <tr >
      <td width="87%" height="25">&nbsp;</td>
    </tr>
    <tr >
      <td height="25" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
    </tr>
  </table>

<input type="hidden" name="set_group">
<input type="hidden" name="prepareToEdit" value=" <%=WI.getStrValue(strPrepareToEdit,"0")%>">
<input type="hidden" name="page_action" value="">
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="show_list" value="<%=WI.fillTextValue("show_list")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>