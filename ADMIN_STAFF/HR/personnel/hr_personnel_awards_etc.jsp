<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoScholarship" %>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	
	if (WI.fillTextValue("print_page").equals("1")) { %>
	<jsp:forward page="./hr_personnel_awards_etc_print.jsp" />
<%	return;}


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
function UpdateClassCatg(){
	var vClassification = document.staff_profile.classification.value;
	if(vClassification.length == 0){
		alert("No classification selected.");
		return;
	}
	
	var loadPg = "./hr_reward_classification_catg.jsp?classification_index="+vClassification;
	var win=window.open(loadPg,"UpdateClassCatg",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function UpdateSubCatg(){
	var vRewardType = document.staff_profile.award_type.value;
	if(vRewardType.length == 0){
		alert("No award type selected.");
		return;
	}
	
	var loadPg = "./hr_reward_subcatg.jsp?awardIndex="+vRewardType;
	var win=window.open(loadPg,"UpdateSubCatg",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function ChangeRewardType(){
	document.staff_profile.labelname.value = document.staff_profile.award_type[document.staff_profile.award_type.selectedIndex].text;
	ReloadPage();
}
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField,strMaxLen){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=staff_profile&opner_form_field="+strFormField+"&max_len="+strMaxLen;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function viewScholarshipList(strIndex,strAwardIndex)
{
	var loadPg = "./hr_updatescholarlist.jsp?labelName="+strIndex+"&awardIndex="+strAwardIndex;
	var win=window.open(loadPg,"newWin",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function DeleteRecord(index)
{
	document.staff_profile.print_page.value="";	
	document.staff_profile.page_action.value="0";
	document.staff_profile.info_index.value = index;
}

function ReloadPage()
{
	document.staff_profile.print_page.value="";	
	document.staff_profile.reloadPage.value = "1";
	document.staff_profile.submit();
}

function PrepareToEdit(index){
	document.staff_profile.print_page.value="";	
	document.staff_profile.prepareToEdit.value = "1";
	document.staff_profile.setEdit.value = "0";
	document.staff_profile.info_index.value = index;
	ReloadPage();
}

function CancelRecord(index){
	location = "./hr_personnel_awards_etc.jsp?my_home=<%=WI.fillTextValue("my_home")%>";
}
function viewInfo(){
	document.staff_profile.print_page.value="";	
	this.SubmitOnce("staff_profile");
	
}

function AddRecord(){
	document.staff_profile.print_page.value="";	
	document.staff_profile.page_action.value="1";
	document.staff_profile.hide_save.src = "../../../images/blank.gif";
	document.staff_profile.submit();
}

function PrintPg(){
	document.staff_profile.print_page.value="1";
	document.staff_profile.submit();
}

function EditRecord(){
	document.staff_profile.print_page.value="";	
	document.staff_profile.page_action.value="2";
	document.staff_profile.submit();
}
function FocusID() {
<% if(WI.fillTextValue("my_home").compareTo("1") != 0){%>
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
function loadClassCatg() {	
	var objCOA=document.getElementById("load_class_catg");
	var header = "Select Classification Catg";
	var selName = "classification_catg";
	var onChange = "";
	var tableName = "hr_reward_class_catg";
	var fields = "class_catg_index,class_catg_name";
	
	var vClassValue = document.staff_profile.classification.value;
	if(vClassValue.length == 0)
		vClassValue = '0';
//	alert(String.charCodeAt("="));
	var vCondition = ' where classification_index@'+vClassValue;
//	alert(vCondition);
	
	//String strOnChange = WI.fillTextValue("onchange");
    //String strSelName = WI.fillTextValue("sel_name");
    //String strTableName = WI.fillTextValue("table_name");
    //String strCondition = WI.fillTextValue("condition");
    //String strFields = WI.fillTextValue("fields");
    //String strHeader = WI.fillTextValue("header");
	
	this.InitXmlHttpObject(objCOA, 2);//I want to get innerHTML in this.retObj
	if(this.xmlHttp == null) {
		alert("Failed to init xmlHttp.");
		return;
	}
	var strURL = "../../../Ajax/AjaxInterface.jsp?methodRef=20400&query_con="+vCondition+"&onchange="+onChange+"&sel_name="+selName+"&table_name="+tableName+"&fields="+fields+"&header="+header;
//	alert(strURL);
	this.processRequest(strURL);
}
</script>
<%
	
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;


	boolean bolMyHome = false;
	if (WI.fillTextValue("my_home").equals("1")) 
		bolMyHome = true;
//add security hehol.

	String strSchCode = (String)request.getSession(false).getAttribute("school_code");
	if (strSchCode == null ) 
		strSchCode = "";
	boolean bolAUF = strSchCode.startsWith("AUF");

	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Education","hr_personnel_awards_etc.jsp.jsp");

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
														"hr_personnel_awards_etc.jsp.jsp");
// added for AUF
strTemp = (String)request.getSession(false).getAttribute("userId");
if (strTemp != null ){
	if(bolMyHome){
		if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").equals("1"))
			iAccessLevel = 2;
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
Vector vEditResult = null;
String strPrepareToEdit = null;
boolean bNoError = true;
boolean bSetEdit = false;  // to be set when preparetoedit is 1 and okey to edit
String strInfoIndex = WI.fillTextValue("info_index");

strPrepareToEdit = WI.getStrValue(request.getParameter("prepareToEdit"),"0");
String strReloadPage = WI.getStrValue(request.getParameter("reloadpage"),"0");

HRInfoScholarship hrS = new HRInfoScholarship();

int iAction =  -1;

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

if (strTemp.trim().length()>0){
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
		vRetResult = hrS.operateOnScholarship(dbOP,request,iAction);

		switch(iAction){
			case 0:{ // delete record
				if (vRetResult != null)
					strErrMsg = " Employee award record removed successfully.";
				else
					strErrMsg = hrS.getErrMsg();

				break;
			}
			case 1:{ // add Record
				if (vRetResult != null)
					strErrMsg = " Employee award record added successfully.";
				else
					strErrMsg = hrS.getErrMsg();
				break;
			}
			case 2:{ //  edit record
				if (vRetResult != null){
					strErrMsg = " Employee award record edited successfully.";
					strPrepareToEdit = "0";}
				else
					strErrMsg = hrS.getErrMsg();
				break;
			}
		}
	}
}

if (strPrepareToEdit.equals("1")){
	vEditResult = hrS.operateOnScholarship(dbOP,request,3);

	if (vEditResult != null && vEditResult.size() > 0){
		bSetEdit = true;
	}
}
boolean bolAllowUpdate = false;
if(strSchCode.startsWith("CIT"))
	bolAllowUpdate = true;
%>
<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic">
<form action="" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3" align="center" bgcolor="#A49A6A" class="footerDynamic"><font color="#FFFFFF" ><strong>:::: 
        AWARDS/CITATIONS/RECOGNITIONS PAGE ::::</strong></font></td>
    </tr>
    <tr> 
      <td height="25" colspan="3">&nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
<%if(bolAUF){%>
	<tr>
		<td height="25" colspan="3">&nbsp;&nbsp;<i><font size="2">Definition: The acknowledgement of an achievement, merit, outstanding service or devotion to duty etc.</font></i>		</td>
	</tr>
<%}
if (!bolMyHome){%>
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
  <% if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 0){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr>
      <td width="100%"><hr size="1">
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
        <table width="98%" border="0" align="center" cellpadding="4" cellspacing="0">
          <tr>
            <td width="1%" rowspan="11">&nbsp;</td>
            <td width="25%">Reward Type</td>
            <td width="74%"> <select name="award_type" onChange='ChangeRewardType();'>
                <option value="">Select Reward Type</option>
<%
	strTemp = WI.fillTextValue("award_type");
	if (bSetEdit && strPrepareToEdit.equals("1")){
		strTemp = (String)vEditResult.elementAt(2);
	}
%>
                <%=dbOP.loadCombo("REWARD_TYPE_INDEX","REWARD_NAME"," FROM HR_REWARD_TYPE order by reward_name",strTemp,false)%> </select> <strong>
<%if((!bolMyHome || bolAllowUpdate) && iAccessLevel > 1 && !strSchCode.startsWith("AUF")){%>
	 			 <a href='javascript:viewList("HR_REWARD_TYPE","REWARD_TYPE_INDEX","REWARD_NAME","TYPE OF REWARDS",
				"HR_REWARD_NAME","REWARD_TYPE_INDEX", " and HR_REWARD_NAME.is_del = 0","","award_type","64")'>
				 <img src="../../../images/update.gif" border="0"></a>
<%}%>
		</strong><font size="1">click to add type of reward in the list</font> </td>
          </tr>
	<%if (strTemp.length() > 0) {
		if(bolAUF){%>
          <tr>
		  	<td>Sub-category</td>
            <td>
				<%
					strErrMsg =
						" from hr_reward_type_catg "+
						" where reward_type_index = "+strTemp+
						" order by category_name ";
						
					strTemp = WI.fillTextValue("sub_catg");
					if (bSetEdit && strPrepareToEdit.equals("1"))
						strTemp = (String)vEditResult.elementAt(10);
				%>
				<select name="sub_catg">
					<option value="">Select Sub-category</option>
					<%=dbOP.loadCombo("catg_index","category_name", strErrMsg, strTemp, false)%>
				</select>
			<%if((!bolMyHome || bolAllowUpdate) && iAccessLevel > 1 && !strSchCode.startsWith("AUF")){%>
				<a href="javascript:UpdateSubCatg();"><img src="../../../images/update.gif" border="0"></a>
				<font size="1">Click to update reward sub-category</font>
			<%}%></td>
          </tr>
          <tr>
		  	<td>Classification</td>
			<td>
				<%
					String strClassification = WI.fillTextValue("classification");
					if(bSetEdit && strPrepareToEdit.equals("1"))
						strClassification = (String)vEditResult.elementAt(11);
				%>
				<select name="classification" onChange="loadClassCatg();">
					<option value="">Select Classification</option>
					<%=dbOP.loadCombo("classification_index","classification_name", " from hr_reward_class order by classification_name", strClassification, false)%>
				</select>
			<%if((!bolMyHome || bolAllowUpdate) && iAccessLevel > 1 && !strSchCode.startsWith("AUF")){%>
				<a href='javascript:viewList("hr_reward_class","classification_index","classification_name","REWARD TYPE CLASSIFICATION",
				"hr_reward_class_catg","classification_index", "","","classification","128")'>
					<img src="../../../images/update.gif" border="0"></a>
				<font size="1">Click to update classification</font>
			<%}%></td>
          </tr>
          <tr>
		  	<td>Classification Catg</td>
			<td>
				<%
					strErrMsg = 
						" from hr_reward_class_catg "+
						" where classification_index = "+WI.getStrValue(strClassification, "0")+
						" order by class_catg_name ";
						
					strTemp = WI.fillTextValue("classification_catg");
					if(bSetEdit && strPrepareToEdit.equals("1"))
						strTemp = (String)vEditResult.elementAt(12);
				%>
				<label id="load_class_catg">
				<select name="classification_catg">
					<option value="">Select Classification Catg</option>
					<%=dbOP.loadCombo("class_catg_index","class_catg_name",strErrMsg, strTemp, false)%>
				</select>
				</label>
			<%if((!bolMyHome || bolAllowUpdate) && iAccessLevel > 1 && !strSchCode.startsWith("AUF")){%>
				<a href="javascript:UpdateClassCatg();"><img src="../../../images/update.gif" border="0"></a>
				<font size="1">Click to update classification catg.</font>
			<%}%></td>
		  </tr>
		<%}%>
          <tr>
            <td><%=WI.fillTextValue("labelname")%></td>
            <td> <select name="award" id="award">
<%
	strTemp2 = WI.fillTextValue("award");
	if (bSetEdit && strPrepareToEdit.equals("1")){
		strTemp2 = (String)vEditResult.elementAt(0);
	}
	
	//this is the award type..
	strErrMsg = WI.fillTextValue("award_type");
	if (bSetEdit && strPrepareToEdit.equals("1")){
		strErrMsg = (String)vEditResult.elementAt(2);
	}
%>
			<option value="">Select <%=WI.fillTextValue("labelname")%> Name</option>
			<%=dbOP.loadCombo("REWARD_INDEX","REWARD"," from HR_REWARD_NAME where REWARD_TYPE_INDEX="+strErrMsg+ " order by reward",strTemp2,false)%>
              </select> <strong> 
<%if((!bolMyHome || bolAllowUpdate) && iAccessLevel > 1){%>
			  <a href='javascript:viewScholarshipList("<%=WI.fillTextValue("labelname")%>","<%=WI.fillTextValue("award_type")%>")'><img src="../../../images/update.gif" border="0"></a>
<%}%>
              </strong><font size="1">click to add <%=WI.fillTextValue("labelname")%> in the list </font></td>
          </tr>
<% if (strSchCode.startsWith("UI")){
	if (bSetEdit && strPrepareToEdit.equals("1")){
		strTemp = WI.getStrValue((String)vEditResult.elementAt(9));
		strTemp = ConversionTable.replaceString(strTemp,",","");
	}else{
		strTemp = WI.fillTextValue("amount");
	}
%> 
	 <tr>
		<td height="28">&nbsp;Amount: </td>
		<td>
			<input name="amount" type= "text" value ="<%=strTemp%>"
			 class="textbox"   onfocus="style.backgroundColor='#D3EBFF'" 
			onBlur="style.backgroundColor='white'" size="6" maxlength="12"
			onKeyUp="AllowOnlyFloat('staff_profile','amount')">		</td>
	  </tr>
<%}%> 
<% strTemp = WI.fillTextValue("agency");
	strTemp2 = WI.fillTextValue("dategiven");
	if (bSetEdit && strPrepareToEdit.equals("1")){
		strTemp  = (String)vEditResult.elementAt(3);
		strTemp2 = (String)vEditResult.elementAt(4);
	}
%>

          <tr>
            <td height="28">Granting Agency/Org.</td>
            <td><input name="agency" type= "text" value ="<%=WI.getStrValue(strTemp)%>" class="textbox"  id="agency"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="48" maxlength="64"></td>
          </tr>
          <tr>
            <td>Date Given</td>
            <td><p> 
                <input name="dategiven" type="text" value ="<%=WI.getStrValue(strTemp2,"")%>" size="10" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('staff_profile','dategiven','/')"
				 onKeyUp="AllowOnlyIntegerExtn('staff_profile','dategiven','/')">
                <a href="javascript:show_calendar('staff_profile.dategiven');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
              </p>              </td>
          </tr>
<% strTemp = WI.fillTextValue("place");
	strTemp2 = WI.fillTextValue("remarks");
	if (bSetEdit && strPrepareToEdit.equals("1")){
		strTemp  = (String)vEditResult.elementAt(5);
		strTemp2 = (String)vEditResult.elementAt(6);
	}
%>
          <tr>
            <td>Place Given</td>
            <td> <input name="place" type= "text" value ="<%=WI.getStrValue(strTemp,"")%>" class="textbox"  id="a_address23425"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" size="48" maxlength="64"></td>
          </tr>
          <tr>
            <td colspan="2"> Remarks:<br>
              <textarea name="remarks" cols="50" rows="2" id="remarks" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp2,"")%></textarea>            </td>
          </tr>
          <tr>
            <td colspan="2">&nbsp;</td>
          </tr>
          <tr>
            <td>&nbsp;</td>
            <td colspan="2" align="center">
              <% if (iAccessLevel > 1){
	if (strPrepareToEdit.compareTo("1") != 0){%>              <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a>
              <font size="1">click to save entries</font>
              <%}else{ %>              <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a>
              <font size="1">click to save changes</font>
              <%}}%>              <a href='javascript:CancelRecord()'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click
                to cancel and clear entries</font>            </td>
          </tr>
          <%} // end if no reward selected %>
        </table>
        
      </td>
    </tr>
  </table>
<% vRetResult = hrS.operateOnScholarship(dbOP,request,4);
	if (vRetResult != null && vRetResult.size() > 0){ %>
  <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr> 
      <td height="25" colspan="7" align="center" bgcolor="#666666" class="thinborder"><strong><font color="#FFFFFF">EMPLOYEE'S 
        AWARDS RECORD</font></strong></td>
    </tr>
    <tr> 
      <td width="14%" class="thinborder"><font size="1"><strong>&nbsp;REWARD TYPE</strong></font></td>
      <td width="19%" class="thinborder"><font size="1"><strong>&nbsp;NAME</strong></font></td>
      <td width="22%" class="thinborder"><font size="1"><strong>GRANTING AGENCY/ORGANIZATION <br>
      (<font size="1">PLACE</font>) </strong></font></td>
      <td width="9%" class="thinborder"><font size="1"><strong>&nbsp;DATE </strong></font></td>
<% strTemp = "REMARKS ";
	if (strSchCode.startsWith("UI"))
	strTemp += "/ AMOUNT" ;
%>
      <td width="22%" class="thinborder"><strong><font size="1">&nbsp;<%=strTemp%></font></strong></td>
      <td width="6%" class="thinborder"><strong><font size="1">&nbsp;EDIT</font></strong></td>
      <td width="8%" class="thinborder"><font size="1"><strong>&nbsp;DELETE</strong></font></td>
    </tr>
    <% for (int i =0 ; i < vRetResult.size() ; i+=13){ %>
    <tr> 
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+8))%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+1))%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+3),"&nbsp;")%><%=WI.getStrValue((String)vRetResult.elementAt(i+5),"<br>(",")", "&nbsp;")%></font></td>
      <td class="thinborder"><font size="1"><%=WI.getStrValue((String)vRetResult.elementAt(i+4),"&nbsp;")%></font></td>
	  
<% strTemp = WI.getStrValue((String)vRetResult.elementAt(i+6));
	if (strTemp.length() == 0)
		strTemp =  WI.getStrValue((String)vRetResult.elementAt(i+9),"&nbsp;");
	else
		strTemp += " / " + WI.getStrValue((String)vRetResult.elementAt(i+9));
					
%>
      <td class="thinborder">
	    <font size="1"><%=strTemp%></font></td>
      <td class="thinborder"><% if (iAccessLevel > 1){ %> <input type="image" onClick='PrepareToEdit("<%=(String)vRetResult.elementAt(i+7)%>");' src="../../../images/edit.gif" width="40" height="26" border="0"> 
        <%}else{%>
        NA
        <%}%> </td>
      <td class="thinborder"><% if (iAccessLevel == 2){ %>
        <input name="image" type="image" onClick='DeleteRecord("<%=(String)vRetResult.elementAt(i+7)%>");' src="../../../images/delete.gif" border="0"> 
        <%}else{%>
        NA
        <%}%></td>
    </tr>
    <%} // end for loop %>
  </table>
  <table width="100%" border="0" align="center" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr>
      <td height="25" align="center">&nbsp;</td>
    </tr>
    <tr>
      <td width="100%" height="25" align="center"><a href="javascript:PrintPg();"><img src="../../../images/print.gif" width="58" height="26" border="0"></a></td>
    </tr>
    <% for (int i =0 ; i < vRetResult.size() ; i+=10){ %>
    <%} // end for loop %>
  </table>
  <%} // end listing
} // end vEmpRec != null%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3" bgcolor="#FFFFFF">&nbsp;</td>
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
<input type="hidden" name="labelname" value="<%=WI.fillTextValue("labelname")%>">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
<input type="hidden" name="print_page" value="">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>
