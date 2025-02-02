<%@ page language="java" import="utility.*,java.util.Vector,hr.HRManageList,hr.HRInfoLeave" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
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
</head>
<script language="JavaScript" src="../../../jscript/date-picker.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../jscript/td.js"></script>
<SCRIPT LANGUAGE="JavaScript" SRC="../../../Ajax/ajax.js"></script>
<script language="JavaScript">

function viewInfo(){
	ReloadPage();
}

function AddRecord(){
	document.staff_profile.page_action.value="1";
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=staff_profile&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function EditRecord(index)
{
	document.staff_profile.page_action.value="2";
	document.staff_profile.submit();
}

function DeleteRecord(index)
{

	document.staff_profile.page_action.value="0";
	document.staff_profile.info_index.value = index;
	document.staff_profile.submit();
}

function ReloadPage()
{
	document.staff_profile.reloadPage.value = "1";
	document.staff_profile.submit();
}

function ShowHideOthers(strSelFieldName, strOthFieldName,strTextBoxID)
{
	if( eval('document.staff_profile.'+strSelFieldName+'.selectedIndex') == 0)
	{
		eval('document.staff_profile.'+strOthFieldName+'.disabled=false');
		showLayer(strTextBoxID);
	}
	else
	{
		hideLayer(strTextBoxID);
		eval('document.staff_profile.'+strOthFieldName+'.disabled=true');
	}
}

function PrepareToEdit(index){
	document.staff_profile.prepareToEdit.value = "1";
	document.staff_profile.setEdit.value = "0";
	document.staff_profile.info_index.value = index;
	ReloadPage();
}

function CancelRecord(index){
	location = "./hr_personnel_leave.jsp?emp_id="+index+"&my_home=<%=WI.fillTextValue("my_home")%>";
}
function focusID() {
	if(document.staff_profile.emp_id)
		document.staff_profile.emp_id.focus();
}
//all about ajax - to display student list with same name.
function AjaxMapName() {
		var strCompleteName = document.staff_profile.emp_id.value;
		var objCOAInput = document.getElementById("coa_info");
		
		if(strCompleteName.length <=2) {
			objCOAInput.innerHTML = "";
			return ;
		}

		this.InitXmlHttpObject(objCOAInput, 2);//I want to get innerHTML in this.retObj
  		if(this.xmlHttp == null) {
			alert("Failed to init xmlHttp.");
			return;
		}
		var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=2&search_id=1&is_faculty=1&name_format=4&complete_name="+
			escape(strCompleteName);

		this.processRequest(strURL);
}
function UpdateID(strID, strUserIndex) {
	document.staff_profile.emp_id.value = strID;
	document.getElementById("coa_info").innerHTML = "<font size='1' color=blue>...end of processing..</font>";
	document.staff_profile.submit();
}
function UpdateName(strFName, strMName, strLName) {
	//do nothing.
}
function UpdateNameFormat(strName) {
	//do nothing.
}

</script>
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
								"Admin/staff-PERSONNEL-Education","hr_personnel_education.jsp");

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
														"hr_personnel_education.jsp");
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
Vector vRetResult = new Vector();
Vector vEmpRec = new Vector();
Vector vEditResult = new Vector();
String strPrepareToEdit = null;
boolean bNoError = true;
boolean bolSetEdit = false;  // to be set when preparetoedit is 1 and okey to edit
String[] astrConvertUnit= {"","hours", "days"};
String[] astrConvStatus = {"DISAPPROVE","APPROVED","PENDING"};
String strInfoIndex = WI.fillTextValue("info_index");

strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
String strReloadPage = WI.getStrValue(request.getParameter("reloadpage"),"0");

HRManageList hrList = new HRManageList();
HRInfoLeave hrLO = new HRInfoLeave();

int iAction =  0;

iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"3"));

strTemp = WI.fillTextValue("emp_id");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);

if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0){
	request.setAttribute("emp_id",strTemp);
}

if (strTemp.length()> 1){
	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");

	if (vEmpRec != null && vEmpRec.size() > 0)	{
		bNoError = true;
	}else{
		strErrMsg = authentication.getErrMsg();
		bNoError = false;
	}

	if (bNoError) {
		if( iAction == 0 || iAction  == 1 || iAction == 2)
		vRetResult = hrLO.operateOnLeave(dbOP,request,iAction);


		switch(iAction){
			case 0:{ // delete record
				if (vRetResult != null)
					strErrMsg = " Employee leave record removed successfully.";
				else
					strErrMsg = hrLO.getErrMsg();

				break;
			}
			case 1:{ // add Record
				if (vRetResult != null)
					strErrMsg = " Employee leave record added successfully.";
				else
					strErrMsg = hrLO.getErrMsg();
				break;
			}
			case 2:{ //  edit record
				if (vRetResult != null){
					strErrMsg = " Employee leave record edited successfully.";
					strPrepareToEdit = "0";}
				else
					strErrMsg = hrLO.getErrMsg();
				break;
			}
		}
	}
}

if (strPrepareToEdit.compareTo("1") == 0){
	vEditResult = hrLO.operateOnLeave(dbOP,request,3);

	if (vEditResult != null && vEditResult.size() > 0){
		bolSetEdit = true;
	}

	if (WI.fillTextValue("setEdit").compareTo("1") == 0){
		bolSetEdit = false;
	}
}
%>
<body bgcolor="#663300" onLoad="focusID();" class="bgDynamic">

<form action="./hr_personnel_leave.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
          LEAVE APPLICATION'S PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
<% if (!bolMyHome){%>
    <tr valign="top">
      <td width="36%" height="25">&nbsp;Employee ID : 
        <input name="emp_id" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'" value="<%=strTemp%>" onKeyUp="AjaxMapName(1);"></td>
      <td width="7%"> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a> 
			</td>
      <td width="57%"> <a href="javascript:viewInfo()"><img src="../../../images/form_proceed.gif" border="0"></a>
	   <label id="coa_info"></label></td>
    </tr>
<%}else{%>
    <tr>
      <td colspan="3" height="25">&nbsp;Employee ID : <strong><font size="3" color="#FF0000"><%=strTemp%></font></strong>
        <input name="emp_id" type="hidden" value="<%=strTemp%>" ></td>
    </tr>
<%}%>
  </table>
  <% if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){

  strTemp2 = "";
  if (WI.fillTextValue("pending").length() != 0){
  	strTemp2 = "checked";
  }
%>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td width="100%" height="25"><input name="pending" type="checkbox" id="pending" value="1" <%=strTemp2%>>
        Show only pending Applications (Optional)</td>
    </tr>
    <tr>
      <td height="25"><hr size="1">
        <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
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
              <%="Length of Service : <br>" + new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></font> 
            </td>
          </tr>
        </table>
        <br>
<%
	strTemp = WI.fillTextValue("lindex");
	strTemp2 = WI.fillTextValue("wpay");
	strTemp3 = WI.fillTextValue("datefiled");
	if (bolSetEdit && strPrepareToEdit.compareTo("1") == 0){
		strTemp = (String)vEditResult.elementAt(1);
		strTemp2 = (String)vEditResult.elementAt(3);
		strTemp3 = (String)vEditResult.elementAt(4);
	}
%>
		<table width="92%" border="0" cellpadding="5" cellspacing="0">
          <tr>
            <td width="9%" rowspan="6">&nbsp;</td>
            <td width="22%">Type of Leave</td>
            <td width="69%"><select name="lindex" id="lindex">
                <option value="">Select Type of Leave</option>
                <%=dbOP.loadCombo("benefit_index","sub_type"," from hr_preload_benefit_type join hr_benefit_incentive" +
				" on (hr_preload_benefit_type.benefit_type_index = hr_benefit_incentive.benefit_type_index)"+
				" where benefit_name like 'leave%' and IS_INCENTIVE = 0 and is_valid = 1 and is_del = 0 order by sub_type"  ,strTemp,false)%> 
              </select>
              &nbsp;&nbsp;Available Leave : <strong>$AVAILABLE 
              </strong></td>
          </tr>
          <tr>
            <td bgcolor="#FFFCF4">&nbsp;</td>
            <td bgcolor="#FFFCF4"> 
			<% if (strTemp2.compareTo("0") == 0){%>
			<input type="radio" name="wpay" value="0" checked>With Pay &nbsp;&nbsp;
			<%}else{%>
			<input type="radio" name="wpay" value="0">With Pay &nbsp;&nbsp;
			<%} if (strTemp2.compareTo("1") == 0){%>
               <input type="radio" name="wpay" value="1" checked>Without Pay
			<%}else{%>
			<input type="radio" name="wpay" value="1">Without Pay
			<%}%>   
			   </td>
          </tr>
          <tr>
            <td>Date Filed</td>
            <td><input value = "<%=strTemp3%>" name="datefiled" type= "text"  class="textbox"  id="datefiled"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="15" readonly="true">
              <a href="javascript:show_calendar('staff_profile.datefiled');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a></td>
          </tr>
<%
	strTemp = WI.fillTextValue("caddress");
	strTemp2 = WI.fillTextValue("tel");
	strTemp3 = WI.fillTextValue("cell");
	if (bolSetEdit && strPrepareToEdit.compareTo("1") == 0){
		strTemp = (String)vEditResult.elementAt(5);
		strTemp2 = (String)vEditResult.elementAt(6);
		strTemp3 = (String)vEditResult.elementAt(7);
	}
%>
          <tr>
            <td>Contact Address while on Leave</td>
            <td><input value="<%=strTemp%>" name="caddress" type="text" id="caddress" size="48" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ></td>
          </tr>
          <tr>
            <td>Tel. No.</td>
            <td><input value="<%=strTemp2%>"  name="tel" type="text" id="tel" size="25"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ></td>
          </tr>
          <tr>
            <td>Cell No.</td>
            <td><input  value="<%=strTemp3%>" name="cell" type="text" id="cell" size="25"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ></td>
          </tr>
<%
	strTemp = WI.fillTextValue("ldatefrom");
	strTemp2 = WI.fillTextValue("hrfrom");
	strTemp3 = WI.fillTextValue("fmin");
	if (bolSetEdit && strPrepareToEdit.compareTo("1") == 0){
		strTemp = (String)vEditResult.elementAt(8);
		strTemp2 = (String)vEditResult.elementAt(9);
		strTemp3 = (String)vEditResult.elementAt(10);
	}
%>       <tr>
            <td colspan="3"> <table width="100%" border="0" align="center" cellpadding="5" cellspacing="0">
                <tr>
                  <td width="9%">&nbsp;</td>
                  <td width="17%" rowspan="3" bgcolor="#F0EFF1">Date(s) of Leave</td>
                  <td width="11%" bgcolor="#F0EFF1">(FROM) </td>
                  <td width="63%" bgcolor="#F0EFF1"><input  value="<%=strTemp%>" name="ldatefrom" type= "text" class="textbox"  id="ldatefrom"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="15" readonly="true">
                    <a href="javascript:show_calendar('staff_profile.ldatefrom');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
                    Time
                    <input  value="<%=strTemp2%>" name="hrfrom" type= "text" class="textbox"  id="hrfrom"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" size="4" maxlength="2">
                    :
                    <input  value="<%=strTemp3%>" name="fmin" type= "text" class="textbox"  id="fmin"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" size="4" maxlength="2">
<%
	strTemp = WI.fillTextValue("frAMPM");
	strTemp2 = WI.fillTextValue("onedate");
	strTemp3 = WI.fillTextValue("ldateto");
	if (bolSetEdit && strPrepareToEdit.compareTo("1") == 0){
		strTemp = (String)vEditResult.elementAt(11);
		strTemp2 = (String)vEditResult.elementAt(18);
		strTemp3 = (String)vEditResult.elementAt(12);
	}
	if (strTemp2 != null && strTemp2.compareTo("1") == 0) 
		strTemp2 = "checked";
	else
		strTemp2 = "";
%>
                    <select name="frAMPM" id="hrFampm">
	
                      <option value="0">AM</option>
    				<% if (strTemp.compareTo("1") == 0) {%>
	                  <option value="1" selected>PM</option>
					 <%}else{%>
	                  <option value="1">PM</option>
					 <%}%>					
                    </select></td>
                </tr>
                <tr>
                  <td width="9%">&nbsp;</td>
                  <td bgcolor="#F0EFF1">&nbsp;</td>
                  <td bgcolor="#F0EFF1"><input name="onedate" type="checkbox" id="onedate" value="1" <%=strTemp2%>>
                    <font size="1">Check if leave is only for a day or less</font></td>
                </tr>
                <tr>
                  <td width="9%">&nbsp;</td>
                  <td bgcolor="#F0EFF1"> (TO) </td>
                  <td bgcolor="#F0EFF1"><input value="<%=strTemp3%>" name="ldateto" type= "text"  class="textbox"  id="a_address423"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="15" readonly="true">
                    <a href="javascript:show_calendar('staff_profile.ldateto');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>
                    Time
<%
	strTemp = WI.fillTextValue("hrto");
	strTemp2 = WI.fillTextValue("minto");
	strTemp3 = WI.fillTextValue("toAMPM");
	if (bolSetEdit && strPrepareToEdit.compareTo("1") == 0){
		strTemp = (String)vEditResult.elementAt(13);
		strTemp2 = (String)vEditResult.elementAt(14);
		strTemp3 = (String)vEditResult.elementAt(15);
	}
%>
                    <input  value="<%=strTemp%>" name="hrto" type= "text" class="textbox"  id="a_address232"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" size="4" maxlength="2">
                    :
                    <input  value="<%=strTemp2%>" name="minto" type= "text" class="textbox" id="minto"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeypress=" if(event.keyCode<48 || event.keyCode > 57) event.returnValue=false;" size="4" maxlength="2">
                    <select name="toAMPM" id="toAMPM">
                      <option value="0">AM</option>
					<% if (strTemp3.compareTo("1") == 0) {%>
                      <option value="1" selected>PM</option>
					<%}else{%>
                      <option value="1">PM</option>
					<%}%>
                    </select></td>
                </tr>
              </table></td>
          </tr>
<%
	strTemp = WI.fillTextValue("duration");
	strTemp2 = WI.fillTextValue("dIndex");
	strTemp3 = WI.fillTextValue("reason");
	if (bolSetEdit && strPrepareToEdit.compareTo("1") == 0){
		strTemp = (String)vEditResult.elementAt(19);
		strTemp2 = (String)vEditResult.elementAt(20);
		strTemp3 = (String)vEditResult.elementAt(21);
	}
%>
          <tr>
            <td width="9%">&nbsp;</td>
            <td>Duration</td>
            <td><input value="<%=strTemp%>" name="duration" type= "text" class="textbox"  id="duration"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="5" onKeypress=" if(event.keyCode<46 || event.keyCode== 47 || event.keyCode > 57) event.returnValue=false;">
              <select name="dIndex" id="dIndex">
                <option value="1">hours</option>
			 <% if (strTemp2.compareTo("2") == 0 ) {%>
                <option value="2" selected>days</option>
			 <%}else{%>
                <option value="2">days</option>
			 <%}%>
              </select></td>
          </tr>
          <tr>
            <td width="9%">&nbsp;</td>
            <td colspan="2">Explanation : <br>
              <textarea name="reason" cols="64"  id="reason"  class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" ><%=strTemp3%></textarea>
            </td>
          </tr>
<%
	strTemp = WI.fillTextValue("substitute");
	if (bolSetEdit && strPrepareToEdit.compareTo("1") == 0){
		strTemp = (String)vEditResult.elementAt(22);
	}
%>
          <tr>
            <td width="9%">&nbsp;</td>
            <td>Substitute Employee</td>
            <td><select name="substitute" id="substitute">
                <option value="" >Select Substitute </option>
                <%=dbOP.loadCombo("USER_INDEX","ID_NUMBER",
				" FROM USER_TABLE WHERE (AUTH_TYPE_INDEX <>4 and AUTH_TYPE_INDEX<>6) or AUTH_TYPE_INDEX is null ",strTemp,false)%>
              </select> </td>
          </tr>
<%
	strTemp = "&nbsp";
	strTemp2 = "&nbsp";
	strTemp3 = "&nbsp";
	if (bolSetEdit && strPrepareToEdit.compareTo("1") == 0){
		strTemp = hrLO.getApprovalStatus(dbOP,"supervisor", (String)vEditResult.elementAt(0));
		strTemp2 = hrLO.getApprovalStatus(dbOP,"hr", (String)vEditResult.elementAt(0));
		strTemp3 = hrLO.getApprovalStatus(dbOP,"president", (String)vEditResult.elementAt(0));
	}
%>
          <tr>
            <td width="9%">&nbsp;</td>
            <td>Supervisor's Approval</td>
            <td><%=strTemp%></td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td>HR's Approval</td>
            <td><%=strTemp%></td>
          </tr>
          <tr>
            <td width="9%" height="29">&nbsp;</td>
            <td>President's Approval</td>
            <td><%=strTemp3%></td>
          </tr>
<%
	strTemp2 = WI.fillTextValue("rdate");
	strTemp3 = WI.fillTextValue("rtntime");
	if (bolSetEdit && strPrepareToEdit.compareTo("1") == 0){
		strTemp2 = (String)vEditResult.elementAt(23);
		strTemp3 = (String)vEditResult.elementAt(24);
	}
%>
          <tr>
            <td width="9%">&nbsp;</td>
            <td colspan="2"><br>
              Return Date : 
              <input name="rdate" type= "text" class="textbox"  id="a_address3"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="15" readonly="true">
              <a href="javascript:show_calendar('staff_profile.rdate');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
              &nbsp;&nbsp;&nbsp;&nbsp; Return Time : 
              <input name="rtntime" type= "text"  class="textbox"  id="a_address32"  onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="15" readonly="true">
            </td>
          </tr>
          <tr>
            <td colspan="3"> <div align="center">
                <% if (iAccessLevel > 1){
	if (strPrepareToEdit.compareTo("1") != 0){%>
                <input name="image" type="image" onClick="AddRecord();" src="../../../images/save.gif" width="48" height="28">
                <font size="1">click to save entries</font>
                <%}else{ %>
                <input name="image" type="image" onClick="EditRecord()" src="../../../images/edit.gif" border="0">
                <font size="1">click to save changes</font><a href='javascript:CancelRecord("<%=request.getParameter("emp_id")%>")'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click
                to cancel and clear entries</font>
                <%}}%>
              </div></td>
          </tr>
        </table>
        <br>
<%	vRetResult = hrLO.operateOnLeave(dbOP,request, 4);
	if (vRetResult != null && vRetResult.size() > 0){%>

		<table width="100%" border="1" align="center" cellpadding="3" cellspacing="0">
          <tr bgcolor="#666666">
            <td colspan="7"><div align="center"><font color="#FFFFFF"><strong>LIST
                OF LEAVES</strong></font></div></td>
          </tr>
          <tr>
            <td width="20%"> <p><font size="1"><strong> TYPE OF LEAVE<br>
                </strong></font></p></td>
            <td width="23%"><font size="1"><strong>INCLUSIVE DATES</strong></font></td>
            <td width="12%"><font size="1"><strong>DURATION</strong></font></td>
            <td width="11%"><font size="1"><strong>STATUS</strong></font></td>
            <td width="8%" align="center"><font size="1"><strong>EDIT</strong></font></td>
            <td width="12%"><font size="1"><strong> PROCESS APPLICATION</strong></font></td>
            <td width="14%"><font size="1"><strong>DELETE APPLICATION</strong></font></td>
          </tr>
<% for (int i=0; i < vRetResult.size() ; i+=32) {
	strTemp = (String)vRetResult.elementAt(i+31);
	
	if (strTemp == null) strTemp = "Not Applicable";
	else	strTemp = astrConvStatus[Integer.parseInt(strTemp)];
%>
          <tr>
            <td><p><font size="1"><%=(String)vRetResult.elementAt(i+2)%><br>
                </font></p></td>
            <td><font size="1"><%=(String)vRetResult.elementAt(i+8) + WI.getStrValue((String)vRetResult.elementAt(i+12)," -  ","","")%></font></td>
            <td><font size="1"><%=(String)vRetResult.elementAt(i+19) + " " + astrConvertUnit[Integer.parseInt((String)vRetResult.elementAt(i+20))]%> </font></td>
            <td><font size="1"><%=strTemp%></font></td>
            <td align="center"><a href="javascript:PrepareToEdit('<%=(String)vRetResult.elementAt(i)%>');"><img name="image2" src="../../../images/edit.gif" width="40" height="26" border="0"></a></td>
            <td align="center"><a href="./hr_personnel_leavedetails.jsp?info_index=<%=(String)vRetResult.elementAt(i)%>&emp_id=<%=WI.fillTextValue("emp_id")%>"><img src="../../../images/view.gif" border="0"></a></td>
            <td align="center"><a href="javascript:DeleteRecord('<%=(String)vRetResult.elementAt(i)%>');"><img name="image3" src="../../../images/delete.gif" border="0"></a></td>
          </tr>
<%} // end for loop%>
        </table>
<%}%>
        <hr size="1"></td>
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
<input type="hidden" name="page_action">
<input type="hidden" name="reloadPage" value="<%=strReloadPage%>">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="setEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>

