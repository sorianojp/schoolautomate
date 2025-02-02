<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoGAExtraActivityOffense, hr.HRUtil,
																java.sql.PreparedStatement"%>
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
<script language="JavaScript" src="../../../jscript/common.js"></script>
<script language="JavaScript" src="../../../Ajax/ajax.js"></script>

<script language="JavaScript">

function PrepareToEdit(index){
	document.staff_profile.prepareToEdit.value = "1";
	document.staff_profile.info_index.value = index;
	this.SubmitOnce("staff_profile");
}

function viewInfo(){
	this.SubmitOnce("staff_profile");
}

function AddRecord(){
	document.staff_profile.page_action.value="1";
	this.SubmitOnce("staff_profile");
}

function EditRecord(){

	document.staff_profile.page_action.value="2";
	this.SubmitOnce("staff_profile");
}

function DeleteRecord(index){
	document.staff_profile.page_action.value="0";
	document.staff_profile.info_index.value = index;
	this.SubmitOnce("staff_profile");
}

function CancelRecord(index)
{
	location = "./hr_personnel_affiliations.jsp?my_home=<%=WI.fillTextValue("my_home")%>";
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=staff_profile&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function FocusID() {
<% if (WI.fillTextValue("my_home").compareTo("1") != 0) {%>
	document.staff_profile.emp_id.focus();
<%}%>
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=staff_profile.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
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

function copyName(){
	if (document.staff_profile.group_names.selectedIndex != 0) 
		document.staff_profile.name.value= 
			document.staff_profile.group_names[document.staff_profile.group_names.selectedIndex].text;
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
								"Admin/staff-PERSONNEL-Education","hr_personnel_affiliations.jsp");

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
														"hr_personnel_affiliations.jsp");
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

Vector vEmpRec = null;
Vector vRetResult = null;
Vector vEditInfo = null;
boolean bNoError = false;
boolean bolNoRecord = false;
String strPrepareToEdit = null;
String strInfoIndex = WI.fillTextValue("info_index");

PreparedStatement pstTest = null;
String strSQLQuery = "select * from user_table where user_index = ?";
pstTest = dbOP.getPreparedStatement(strSQLQuery);

HRInfoGAExtraActivityOffense hrCon = new HRInfoGAExtraActivityOffense();

int iAction =  -1;

iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"3"));
strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");

strTemp = WI.fillTextValue("emp_id");
if(strTemp.length() == 0)
	strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
else	
	request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
strTemp = WI.getStrValue(strTemp);

if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0){
	request.setAttribute("emp_id",strTemp);
}

if (strTemp.trim().length()> 0){

	enrollment.Authentication authentication = new enrollment.Authentication();
    vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");


	if (vEmpRec != null && vEmpRec.size() > 0){
		bNoError = true;
	}else{
		strErrMsg = "Employee has no profile.";
		bNoError = false;
	}

	if (bNoError) {
		if (iAction == 0 || iAction == 1 || iAction  == 2)
		vRetResult = hrCon.operateOnGroupAffiliation(dbOP,request,iAction);

		switch(iAction){
			case 0:{ // delete record
				if (vRetResult != null)
					strErrMsg = " Employee group affiliation record removed successfully.";
				else
					strErrMsg = hrCon.getErrMsg();

				break;
			}
			case 1:{ // add Record
				if (vRetResult != null)
					strErrMsg = " Employee group affiliation record added successfully.";
				else
					strErrMsg = hrCon.getErrMsg();
				break;
			}
			case 2:{ //  edit record
				if (vRetResult != null){
					strErrMsg = " Employee group affiliation record edited successfully.";
					strPrepareToEdit = "0";}
				else
					strErrMsg = hrCon.getErrMsg();
				break;
			}
		} //end switch
	}// end bNoError
}

if (strPrepareToEdit != null && strPrepareToEdit.compareTo("1") == 0){
	vEditInfo = hrCon.operateOnGroupAffiliation(dbOP,request,3);

	bNoError = false;

	if (vEditInfo != null && vEditInfo.size() > 0){
		bNoError = true;
	}else{
		strErrMsg = hrCon.getErrMsg();
	}
}

vRetResult = hrCon.operateOnGroupAffiliation(dbOP,request,4);
if (vRetResult == null && strErrMsg == null){
	strErrMsg = hrCon.getErrMsg();
}

%>
<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<form action="./hr_personnel_affiliations.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>::::
          GROUP AFFILIATIONS PAGE ::::</strong></font></div></td>
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
	   <label id="coa_info"></label>
		 </td>
    </tr>
<%}else{%>
    <tr>
      <td colspan="3" height="25">&nbsp;Employee ID : <strong><font size="3" color="#FF0000"><%=strTemp%></font></strong>
        <input name="emp_id" type="hidden" value="<%=strTemp%>" ></td>
    </tr>
<%}%>
  </table>
  <%if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td width="103%"><hr size="1">
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
<%
	if (bNoError && strPrepareToEdit.compareTo("1") == 0){
		strTemp =  (String) vEditInfo.elementAt(0);
		strTemp2 = (String) vEditInfo.elementAt(1);
		strTemp3 = (String) vEditInfo.elementAt(2);
	}else{
		strTemp = WI.fillTextValue("name");
		strTemp2 = WI.fillTextValue("place");
		strTemp3 = WI.fillTextValue("position");
	}
%>
        <br> <table width="92%" border="0" align="center">
          <tr>
            <td>&nbsp;</td>
            <td>Select from existing </td>
            <td>
						<select name="group_names" onChange="copyName();">
              <option value="">Select affiliation</option>
              <%=dbOP.loadCombo("distinct ORGANIZATION_NAME","ORGANIZATION_NAME"," FROM HR_INFO_AFFILIATION order by ORGANIZATION_NAME",strTemp,false)%>
            </select></td>
          </tr>
          <tr>
            <td width="10%">&nbsp;</td>
            <td width="22%">Name of Organization</td>
            <td width="68%">
						<input name="name" type="text" value="<%=WI.getStrValue(strTemp,"")%>" class="textbox"  
						onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="name" 
						size="45" onKeyUp = "AutoScrollList('staff_profile.name','staff_profile.group_names',true);"></td>
          </tr>
          <tr>
            <td width="10%">&nbsp;</td>
            <td>Place/Station</td>
            <td><input name="place" type= "text" value="<%=WI.getStrValue(strTemp2,"")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="place" size="32"></td>
          </tr>
          <tr>
            <td width="10%">&nbsp;</td>
            <td>Position</td>
            <td><input name="position" type= "text" value="<%=WI.getStrValue(strTemp3,"")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="position" size="32"></td>
          </tr>
<%
	if (bNoError && strPrepareToEdit.compareTo("1") == 0){
		strTemp =  (String) vEditInfo.elementAt(3);
		strTemp2 = (String) vEditInfo.elementAt(4);
	}else{
		strTemp = WI.fillTextValue("fdate");
		strTemp2 = WI.fillTextValue("tdate");
	}
%>
          <tr>
            <td height="25">&nbsp;</td>
            <td height="25">Inclusive Dates</td>
            <td height="25">From :
              <input name="fdate" type="text"  value="<%=WI.getStrValue(strTemp,"")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="10"
			  onKeyUP="AllowOnlyIntegerExtn('staff_profile','fdate','/')">
              <a href="javascript:show_calendar('staff_profile.fdate');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a><br>
              &nbsp;To &nbsp;&nbsp;&nbsp;: 
              <input name="tdate" type="text"  value="<%=WI.getStrValue(strTemp2,"")%>" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="10"
				onKeyUP="AllowOnlyIntegerExtn('staff_profile','tdate','/')">
              <a href="javascript:show_calendar('staff_profile.tdate');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
              &nbsp; <font size="1">(leave blank if applicable up to present)</font></td>
          </tr>
          <tr>
            <td colspan="3"> <div align="center"> <br>
                <% if (iAccessLevel > 1){
	if (strPrepareToEdit.compareTo("1") != 0 || !bNoError){%>
                <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0"></a>
                <font size="1">click to save entries</font>
                <%}else{ %>
                <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a>
                <font size="1">click to save changes</font>
<%}}%>
                <a href='javascript:CancelRecord()'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
                to cancel and clear entries</font> </div></td>
          </tr>
        </table>
        <br>
 <% if (vRetResult != null && vRetResult.size() > 0) { %>
         <table width="98%" border="1" cellpadding="3" cellspacing="0">
          <tr bgcolor="#828282">
            <td height="25" colspan="5"><div align="center"><font color="#FFFFFF"><strong>LIST
                OF AFFILIATIONS</strong></font></div></td>
          </tr>
          <tr align="center">
            <td width="23%"> <p align="left"><font size="1"><strong> NAME OF ORGANIZATION<br>
                </strong></font></p></td>
            <td width="23%"><font size="1"><strong>PLACE (STATION)</strong></font></td>
            <td width="16%"><font size="1"><strong>POSITION</strong></font></td>
            <td width="21%"><font size="1"><strong>INCLUSIVE DATES</strong></font></td>
            <td width="17%">&nbsp;</td>
          </tr>
<% for (int i=0; i < vRetResult.size() ; i+=6) {
	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+3));
	if (strTemp.length() > 0){
		strTemp += WI.getStrValue((String)vRetResult.elementAt(i+4), " to " ,"", " to present");
	}else strTemp = "&nbsp;";
%>
          <tr>
            <td><font size="1"><%=(String)vRetResult.elementAt(i)%><br>
              </font></td>
            <td><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+1),"&nbsp")%></font></td>
            <td><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+2),"&nbsp")%></font></td>
            <td><font size="1"><%=WI.getStrValue(strTemp)%></font></td>
            <td>
              <% if (iAccessLevel > 1) {%>
              <a href="javascript:PrepareToEdit('<%=WI.getStrValue((String)vRetResult.elementAt(i+5))%>')"><img src="../../../images/edit.gif" width="40" height="26" border="0"></a>
              <% if (iAccessLevel == 2) {%>
              <a href="javascript:DeleteRecord('<%=WI.getStrValue((String)vRetResult.elementAt(i+5))%>')"><img src="../../../images/delete.gif" border="0"></a>
              <%}}%>
              &nbsp;</td>
          </tr>
<%}// end for loop%>
        </table>
<%} // end for listing table%>
      </td>
    </tr>
  </table>
  <%}%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#999966" class="footerDynamic">&nbsp;</td>
      </tr>
  </table>
  <input type="hidden" name="info_index" value="<%=strInfoIndex%>">
  <input type="hidden" name="page_action">
  <input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
  <input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
