<%@ page language="java" import="utility.*,java.util.Vector,hr.HRInfoLicenseETSkillTraining"%>
<%
	DBOperation dbOP = null;
	WebInterface WI = new WebInterface(request);
	boolean bolMyHome = false;
	if(WI.fillTextValue("my_home").compareTo("1") == 0 ){
		bolMyHome = true;
	}
	String strSchCode = WI.getStrValue((String)request.getSession(false).getAttribute("school_code"));
			
	String[] strColorScheme = CommonUtil.getColorScheme(5);
	//strColorScheme is never null. it has value always.
	
	//if forwarded from training_request_application_view.jsp
	String strIsForwarded = WI.getStrValue(WI.fillTextValue("is_forwarded"), "0");
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
	document.staff_profile.donot_call_close_wnd.value = "1";
	document.staff_profile.prepareToEdit.value = "1";
	document.staff_profile.info_index.value = index;
	this.SubmitOnce("staff_profile");
}

function ReloadPage(){
	document.staff_profile.donot_call_close_wnd.value = "1";
	this.SubmitOnce("staff_profile");
}

function AddRecord(){
	document.staff_profile.donot_call_close_wnd.value = "1";
	document.staff_profile.page_action.value="1";
	document.staff_profile.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce("staff_profile");
}

function EditRecord(){
	document.staff_profile.donot_call_close_wnd.value = "1";
	document.staff_profile.page_action.value="2";
	this.SubmitOnce("staff_profile");
}

function DeleteRecord(index){
	document.staff_profile.donot_call_close_wnd.value = "1";
	document.staff_profile.page_action.value="0";
	document.staff_profile.info_index.value = index;
	this.SubmitOnce("staff_profile");	
}

function CancelRecord(index)
{
	document.staff_profile.donot_call_close_wnd.value = "1";
	location = "./training_request_application.jsp?is_forwarded=<%=WI.fillTextValue("is_forwarded")%>&emp_id="+index+"&my_home=<%=WI.fillTextValue("my_home")%>";
}

function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=staff_profile&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}
function FocusID() {
<% if (!bolMyHome && WI.fillTextValue("is_forwarded").equals("0")) {%>
	document.staff_profile.emp_id.focus();
<%}%>
}
function OpenSearch() {
	var pgLoc = "../../../search/srch_emp.jsp?opner_info=staff_profile.emp_id";
	var win=window.open(pgLoc,"PrintWindow",'width=800,height=600,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function ViewDetail(index) {
	var pgLoc = "./training_request_appl_detail.jsp?info_index="+index+"&emp_id="+document.staff_profile.emp_id.value+
	"&my_home="+document.staff_profile.my_home.value;
	var win=window.open(pgLoc,"PrintWindow",'dependent=yes,width=600,height=400,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
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
	document.staff_profile.donot_call_close_wnd.value = "1";
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
function ReloadParentWnd() {
	if(document.staff_profile.donot_call_close_wnd.value.length > 0)
		return;
	if(document.staff_profile.close_wnd_called.value == "0") 
		window.opener.ShowPage();
}
</script>

<%
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	String strTemp3 = null;
	String strImgFileExt = null;

	//add security here
	try
	{
		dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
								"Admin/staff-PERSONNEL-Request Training","training_request_application.jsp");

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
															"training_request_application.jsp");
	strTemp = (String)request.getSession(false).getAttribute("userId");
	
	if (strTemp != null ){
		if(bolMyHome){
			//System.out.println("iAccessLevel[0]: "+iAccessLevel);
			if(new ReadPropertyFile().getImageFileExtn("ALLOW_HR_EDIT","0").compareTo("1") == 0 || true)
				iAccessLevel  = 2;
			else
				iAccessLevel = 1;
			//System.out.println("iAccessLevel[1]: "+iAccessLevel);
	
			request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
		}
	}
	
	if (strTemp == null) 
		strTemp = "";
	
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
	
	
	HRInfoLicenseETSkillTraining hrCon = new HRInfoLicenseETSkillTraining();
	
	int iAction =  -1;
	
	iAction = Integer.parseInt(WI.getStrValue(request.getParameter("page_action"),"4"));
	
	strPrepareToEdit = WI.fillTextValue("prepareToEdit");
	
	strTemp = WI.fillTextValue("emp_id");
	if(strTemp.length() == 0)
		strTemp = (String)request.getSession(false).getAttribute("encoding_in_progress_id");
	else	
		request.getSession(false).setAttribute("encoding_in_progress_id",strTemp);
	strTemp = WI.getStrValue(strTemp);
	
	if (WI.fillTextValue("emp_id").length() == 0 && strTemp.length() > 0){
		request.setAttribute("emp_id",strTemp);
	}
	
	if (strTemp.trim().length()> 1){
	
		enrollment.Authentication authentication = new enrollment.Authentication();
		vEmpRec = authentication.operateOnBasicInfo(dbOP,request,"0");
		if(vEmpRec == null || vEmpRec.size() ==0)
			strErrMsg = authentication.getErrMsg();
	
		if (vEmpRec != null && vEmpRec.size() > 0)	{
			bNoError = true;
		}else{		
			bNoError = false;
		}
	
		if (bNoError) {
			if (iAction == 0 || iAction == 1 || iAction  == 2)
			vRetResult = hrCon.operateOnTrainingAppl(dbOP,request,iAction);
			
			switch(iAction){
				case 0:{ // delete record
					if (vRetResult != null) {
							strErrMsg = " Employee training request removed successfully.";
					}
					else
						strErrMsg = hrCon.getErrMsg();
	
					break;
				}
				case 1:{ // add Record
					if (vRetResult != null) {
							strErrMsg = " Employee training request added successfully.";
					}
					else
						strErrMsg = hrCon.getErrMsg();
					break;
				}
				case 2:{ //  edit record
					if (vRetResult != null){
							strErrMsg = " Employee training request update successfully.";
							strPrepareToEdit = "";
					}else
						strErrMsg = hrCon.getErrMsg();
					break;
				}
			} //end switch
		}// end bNoError
	}
	
	if (strPrepareToEdit.compareTo("1") == 0){
		vEditInfo = hrCon.operateOnTrainingAppl(dbOP,request,3);
	
		bNoError = false;
	
		if (vRetResult != null && vRetResult.size() > 0){
			bNoError = true;
		}else{
			strErrMsg = hrCon.getErrMsg();
		}	
	}
	
	vRetResult = hrCon.operateOnTrainingAppl(dbOP,request,4);
	if (vRetResult== null && strErrMsg == null){
		strErrMsg = hrCon.getErrMsg();
	}
%>
<body bgcolor="#663300" onLoad="FocusID();" class="bgDynamic" onUnload="ReloadParentWnd();">
<form action="./training_request_application.jsp" method="post" name="staff_profile">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#A49A6A" class="footerDynamic"><div align="center"><font color="#FFFFFF" ><strong>:::: 
           REQUEST FOR TRAININGS PAGE ::::</strong></font></div></td>
    </tr>
    <tr > 
      <td height="25" colspan="3" > &nbsp;&nbsp;<font size="3"><%=WI.getStrValue(strErrMsg)%></font></td>
    </tr>
<% if (!bolMyHome){
	if(strIsForwarded.equals("0")){%>
    <tr>
      <td width="36%" height="25">&nbsp;Employee ID : 
        <input name="emp_id" type="text" class="textbox"   onFocus="style.backgroundColor='#D3EBFF'"
		onBlur="style.backgroundColor='white'" value="<%=strTemp%>" onKeyUp="AjaxMapName(1);"></td>
      <td width="7%"> <a href="javascript:OpenSearch();"><img src="../../../images/search.gif" border="0"></a> 
			</td>
      <td width="57%"> <a href="javascript:ReloadPage()"><img src="../../../images/form_proceed.gif" border="0"></a>
	   <label id="coa_info"></label>
		 </td>
    </tr>
	<%}else{%>
	 <tr>
      <td colspan="3" height="25">&nbsp;Employee ID : <strong><font size="3" color="#0000DD"><%=strTemp%></font></strong>
        <input name="emp_id" type="hidden" value="<%=strTemp%>" ></td>
    </tr>
	<%}
}else{%>
    <tr>
      <td colspan="3" height="25">&nbsp;Employee ID : <strong><font size="3" color="#0000DD"><%=strTemp%></font></strong>
        <input name="emp_id" type="hidden" value="<%=strTemp%>" ></td>
    </tr>
<%}%>
    <tr > 
      <td height="25" colspan="3" ><strong><font color="#FF0000"><font size="2">NOTE 
        : Training Request is invalid, unless, an approved request printout is 
        filed personally in HR Office. </font></font></strong></td>
    </tr>
  </table>
<%if (vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 1){ %>
  <table bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="5">
    <tr> 
      <td width="100%"><hr size="1"> <img src="../../../images/sidebar.gif" width="11" height="270" align="right"> 
        <table width="400" border="0" align="center">
          <tr bgcolor="#FFFFFF"> 
            <td width="100%" valign="middle"> <%strTemp = "<img src=\"../../../upload_img/"+strTemp.toUpperCase()+"."+strImgFileExt+"\" width=150 height=150 align=\"right\" border=\"1\">";%> <%=WI.getStrValue(strTemp)%> <br> <br> <%
	strTemp  = WI.formatName((String)vEmpRec.elementAt(1),(String)vEmpRec.elementAt(2), (String)vEmpRec.elementAt(3),4);
	strTemp2 = (String)vEmpRec.elementAt(15);

	if((String)vEmpRec.elementAt(13) == null)
			strTemp3 = WI.getStrValue((String)vEmpRec.elementAt(14));
	else{
		strTemp3 =WI.getStrValue((String)vEmpRec.elementAt(13));
		if((String)vEmpRec.elementAt(14) != null)
		 strTemp3 += "/" + WI.getStrValue((String)vEmpRec.elementAt(14));
	}
%> <br> <strong><%=WI.getStrValue(strTemp)%></strong><br> <font size="1"><%=WI.getStrValue(strTemp2)%></font><br> <font size="1"><%=WI.getStrValue(strTemp3)%></font><br> <br> <font size=1><%="Date Hired : "  + WI.formatDate((String)vEmpRec.elementAt(6),10)%><br>
              <%=new hr.HRUtil().getServicePeriodLength(dbOP,(String)vEmpRec.elementAt(0))%></font> </td>
          </tr>
        </table>
        <br> 
        <table width="95%" border="0" align="center" cellpadding="0" cellspacing="0">
          <tr> 
            <td width="4%" rowspan="13">&nbsp;</td>
            <td height="25">Date Filed : </td>
            <%	
	if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(1));
	else strTemp = WI.fillTextValue("date_filed");
	
	if (strTemp.length() == 0)
		strTemp = WI.getTodaysDate(1);
%>
            <td height="25">
<%if(bolMyHome){%>
			<input name="date_filed" type="text" value="<%=WI.getStrValue(strTemp,"")%>" size="10" readonly="yes" class="textbox_noborder"> 
<%}else{%>
			<input name="date_filed" type="text" class="textbox" onKeyUp="AllowOnlyIntegerExtn('staff_profile','date_filed','/')" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('staff_profile','date_filed','/')"  value="<%=WI.getStrValue(strTemp,"")%>" size="10" maxlength="10"> 
              <a href="javascript:show_calendar('staff_profile.date_filed');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a>            
<%}%>
			  </td>
          </tr>
          <tr> 
            <td height="30" colspan="2">Name of Seminar/Training:</td>
          </tr>
          <tr> 
            <td height="30" colspan="2"><strong> 
<%	if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(20));
	else strTemp = WI.fillTextValue("training_name_index");
%>
              <select name="training_name_index" >
                <option value="">Select Training/Seminar</option>
                <%=dbOP.loadCombo("TRAINING_NAME_INDEX","TRAINING_NAME"," FROM HR_PRELOAD_TRAINING_NAME order by training_name",strTemp,false)%> 
              </select>
<%if(!bolMyHome && iAccessLevel > 1){%>
              <a href='javascript:viewList("HR_PRELOAD_TRAINING_NAME","TRAINING_NAME_INDEX","TRAINING_NAME","TRAINING NAME",
				"HR_INFO_TRAINING,HR_APPL_INFO_TRAINING","TRAINING_NAME_INDEX, TRAINING_NAME_INDEX", 
				" and HR_INFO_TRAINING.is_del = 0, and HR_INFO_TRAINING.is_del = 0","")'>	
              <img src="../../../images/update.gif" border="0"></a></strong><font size="1">click 
              to add to list of NAME OF SEMINAR/TRAINING</font>
<%}%>
			  </td>
          </tr>
          <tr> 
            <td height="30">Category </td>
            <td height="30"><select name="training_catg">
<%	if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(17));
	else strTemp = WI.fillTextValue("training_catg");
	
	if (strSchCode.startsWith("CPU"))
		strTemp2 = "Internal (Conducted by the University)";
	else
		strTemp2 = "Internal (Held inside the campus)";
		
%>                <option value="0"><%=strTemp2%></option>
       <% 
			if (strSchCode.startsWith("CPU"))
				strTemp2 = "External (Conducted by Other Groups & Attended by CPU Employees)";
			else
				strTemp2 = "External (Held outside the campus)";
				
			if (strTemp.equals("1")) {
				%>
                <option value="1" selected><%=strTemp2%></option>
                <%}else{%>
                <option value="1"><%=strTemp2%></option>
                <%}%>
              </select> </td>
          </tr>
          <tr>
            <td height="25">Scope </td>
            <td height="25"> <select name="seminar_scope">
<%	if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(18));
	else strTemp = WI.fillTextValue("seminar_scope");
%>             <option value="">N/A</option>
                <%=dbOP.loadCombo("train_scope_index","train_scope"," FROM hr_preload_training_scope order by train_scope",strTemp,false)%> 
              </select>
<%if(!bolMyHome && iAccessLevel > 1){%>
              <font size="1"><a href='javascript:viewList("HR_PRELOAD_TRAINING_SCOPE","TRAIN_SCOPE_INDEX","TRAIN_SCOPE","SCOPE OF TRAINING",
				"HR_INFO_TRAINING,HR_APPL_INFO_TRAINING","conducted_by_index, conducted_by_index", 
				" and HR_INFO_TRAINING.is_del = 0, and HR_APPL_INFO_TRAINING.is_del = 0","")'><img src="../../../images/update.gif" border="0"></a>
				click to add to list </font>
<%}%>
			  </td>
          </tr>
          <tr> 
            <td height="28">Type</td>
            <td height="28"><select name="seminar_type">
                <option value = "">N/A</option>
<%
if (vEditInfo != null) 
	strTemp = WI.getStrValue((String)vEditInfo.elementAt(25));
else 
	strTemp = WI.fillTextValue("seminar_type");
%>
            <%=dbOP.loadCombo("training_type_index","training_type"," FROM hr_preload_training_type order by training_type",strTemp,false)%> 
<!--
<%if (strTemp.compareTo("1") == 0){%>
                <option value="1" selected>Official Time </option>
<%}else{%>
                <option value="1">Official Time </option>
<%} if (strTemp.compareTo("2") ==0){%>
                <option value="2" selected>Official Business</option>
<%}else{%>
                <option value="2">Official Business</option>
<%} if (strTemp.compareTo("3") == 0){%>
                <option value="3" selected>Representative/Proxy</option>
<%}else{%>
                <option value="3">Representative/Proxy</option>
<%}%>
-->              </select></td>
          </tr>
          <tr> 
            <td height="30">Requested Budget</td>
<%			   	if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(26));
	else strTemp = WI.fillTextValue("approved_budget");%>
			
            <td height="30"><input name="approved_budget" type="text" class="textbox" value="<%=WI.getStrValue(strTemp)%>"
					onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" onKeyUp="AllowOnlyFloat('staff_profile','approved_budget')" size="12" maxlength="12">            </td>
          </tr>
          <tr> 
            <td width="17%" height="30">Venue</td>
<%	if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(22));
	else strTemp = WI.fillTextValue("venue");
%>			
            <td width="79%" height="30"><font size="1"><strong> 

              <input name="venue" type="text" size="64" maxlength="128" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			  value="<%=WI.getStrValue(strTemp)%>">
              </strong></font></td>
          </tr>
	<% if (strSchCode.startsWith("CPU")) {
	
		if (vEditInfo != null) 
			strTemp = WI.getStrValue((String)vEditInfo.elementAt(32));
		else 
			strTemp = WI.fillTextValue("place");
	%> 
          <tr>
            <td height="30">Place </td>
            <td height="30"><input name="place" type="text" size="64" maxlength="128" class="textbox"  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" 
			  value="<%=WI.getStrValue(strTemp)%>"></td>
          </tr>
	<%}%> 
          <tr> 
            <td height="30">Duration</td>
<%	if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(23));
	else strTemp = WI.fillTextValue("duration");
%>    
            <td height="30"><input name="duration" type= "text" onKeyUp="AllowOnlyFloat('staff_profile','duration')" value="<%=WI.getStrValue(strTemp)%>" class="textbox"
				  onfocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"  id="duration" size="6"> 
              <select name="dIndex" id="dIndex">
                <option value="0" selected>Hours</option>
<%	if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(24));
	else strTemp = WI.fillTextValue("dIndex");			
				if (strTemp.compareTo("1") == 0) {%>
                <option value="1" selected>Days</option>
                <%}else{%>
                <option value="1" >Days</option>
                <%}if (strTemp.compareTo("2") == 0) {%>
                <option value="2" selected>Weeks</option>
                <%}else{%>
                <option value="2" >Weeks</option>
                <%}if (strTemp.compareTo("3") == 0) {%>
                <option value="3" selected>Months</option>
                <%}else{%>
                <option value="3" >Months</option>
                <%}if(strTemp.compareTo("4") == 0) {%>
                <option value="4" selected>Years</option>
                <%}else{%>
                <option value="4" >Years</option>
                <%}%>
              </select> </td>
          </tr>
          <tr> 
            <td height="30">Conducted by</td>
            <td height="30"><font size="1"> 
              <select name="conducted_by_index">
                <option value=""> Select Training Conductor </option>
<%	if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(27));
	else strTemp = WI.fillTextValue("conducted_by_index");%>				
                <%=dbOP.loadCombo("conducted_by_index","conducted_by"," FROM HR_PRELOAD_conducted_by order by conducted_by",strTemp,false)%> 
              </select>
<%if(!bolMyHome && iAccessLevel > 1){%>
              <a href='javascript:viewList("HR_PRELOAD_conducted_by","conducted_by_index","conducted_by","SEMINAR CONDUCTOR",
				"HR_INFO_TRAINING,HR_APPL_INFO_TRAINING","conducted_by_index, conducted_by_index", 
				" and HR_INFO_TRAINING.is_del = 0, and HR_APPL_INFO_TRAINING.is_del = 0","")'>	
              <img src="../../../images/update.gif" border="0"></a><font size="1">click 
              to add to list </font> </font>
<%}%>
			  </td>
          </tr>
          <tr> 
            <td height="30">Inclusive Dates</td>
            <td height="30">From : 
<%	if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(29));
	else strTemp = WI.fillTextValue("incl_date_from");%>			
              <input name="incl_date_from" type="text" class="textbox" id="incl_date_from" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('staff_profile','date_filed','/')" onKeyUp="AllowOnlyIntegerExtn('staff_profile','incl_date_from','/')"  value="<%=WI.getStrValue(strTemp)%>" size="10" maxlength="10"> 
              <a href="javascript:show_calendar('staff_profile.incl_date_from');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
              &nbsp;&nbsp;&nbsp;&nbsp;To: 
<%	if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(30));
	else strTemp = WI.fillTextValue("incl_date_to");%>			  
              <input name="incl_date_to" type="text" class="textbox" id="incl_date_to" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('staff_profile','date_filed','/')" onKeyUp="AllowOnlyIntegerExtn('staff_profile','incl_date_to','/')"  value="<%=WI.getStrValue(strTemp)%>" size="10" maxlength="10">
              <a href="javascript:show_calendar('staff_profile.incl_date_to');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
              <font size="1">(leave date to if seminar is in a day only)</font></td>
          </tr>
          <tr> 
            <td height="30">Notes</td>
<%	if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(31));
	else strTemp = WI.fillTextValue("notes");%>			
            <td height="30"><br> <textarea name="notes" cols="50" rows="2" class="textbox"
			onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=WI.getStrValue(strTemp,"")%></textarea></td>
          </tr>
        </table>
        <hr size="1">
<% if (!bolMyHome && vEditInfo != null) {%>
        <table width="96%" border="0" align="center" cellpadding="2" cellspacing="0">
          <tr> 
            <td width="6%" height="25">&nbsp;</td>
            <td height="25" colspan="2" valign="bottom">Recommending Approval 
              by 1st Signatory: </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td width="26%" height="25"><select name="head_approval">
				<option value="2">Pending</option>
<%if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(2));
	else strTemp = WI.fillTextValue("head_approval");
			if (strTemp.compareTo("1") == 0) {
%>	
	            <option value="1" selected>Approved</option>
<%}else{%>
	            <option value="1">Approved</option>
<%} if (strTemp.compareTo("0") == 0) {%>				
                <option value="0" selected>Disapproved</option>
<%}else{%>
                <option value="0">Disapproved</option>
<%} if (strTemp.compareTo("3") == 0 ){%>
			    <option value="3" selected>Not Required</option>
<%}else{%>
			    <option value="3">Not Required</option>
<%}%>
              </select> 
		    </td>
            <td height="25">Date : 
<%	if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(3));
	else strTemp = WI.fillTextValue("head_date_approval");
%>            <input name="head_date_approval" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('staff_profile','head_date_approval','/')" onKeyUp="AllowOnlyIntegerExtn('staff_profile','head_date_approval','/')"  value="<%=WI.getStrValue(strTemp)%>" size="10" maxlength="10"> 
              <a href="javascript:show_calendar('staff_profile.head_date_approval');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
            </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="2" valign="bottom"> Approval by  2nd Signatory: </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25"><select name="vp_approval">
				<option value="2">Pending</option>
<%	if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(4));
	else strTemp = WI.fillTextValue("head_approval");
				if (strTemp.compareTo("1") == 0) {
%>	            <option value="1" selected>Approved</option>
<%}else{%>
	            <option value="1">Approved</option>
<%}if (strTemp.compareTo("0") == 0) {%>
                <option value="0" selected>Disapproved</option>
<%}else{%>
               <option value="0">Disapproved</option>
<%} if (strTemp.compareTo("3") == 0 ){%>
			    <option value="3" selected>Not Required</option>
<%}else{%>
			    <option value="3">Not Required</option>
<%}%>         </select> </td>
            <td width="68%">Date : 
<%	if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(5));
	else strTemp = WI.fillTextValue("vp_date_approval"); %>
              <input name="vp_date_approval" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('staff_profile','vp_date_approval','/')" onKeyUp="AllowOnlyIntegerExtn('staff_profile','vp_date_approval','/')"  value="<%=WI.getStrValue(strTemp)%>" size="10" maxlength="10"> 
              <a href="javascript:show_calendar('staff_profile.vp_date_approval');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
            </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="2" valign="bottom">Approval by  3rd Signatory:</td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" valign="bottom"> <select name="pres_approval">
				<option value="2">Pending</option>
<%	if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(6));
	else strTemp = WI.fillTextValue("pres_approval"); 
	
		if ( strTemp.compareTo("1") == 0){
	%>			
                <option value="1" selected>Approved</option>
<%}else{%>
                <option value="1">Approved</option>
<%} if (strTemp.compareTo("0")  == 0){%>
                <option value="0" selected>Disapproved</option>
<%}else{%>			
                <option value="0">Disapproved</option>
<%} if (strTemp.compareTo("3") == 0 ){%>
			    <option value="3" selected>Not Required</option>
<%}else{%>
			    <option value="3">Not Required</option>
<%}%>				
              </select> </td>
            <td>Date : 
<%	if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(7));
	else strTemp = WI.fillTextValue("pres_date_approval");  %>
              <input name="pres_date_approval" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white';AllowOnlyIntegerExtn('staff_profile','pres_date_approval','/')" onKeyUp="AllowOnlyIntegerExtn('staff_profile','pres_date_approval','/')"  value="<%=WI.getStrValue(strTemp)%>" size="10" maxlength="10"> 
              <a href="javascript:show_calendar('staff_profile.pres_date_approval');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
            </td>
          </tr>
          <tr> 
            <td height="10" colspan="3"><hr size="1"></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="2">Substitute : 
              <select name="sub_user_index" >
                <option value="" > Substitute Not Necesary </option>
<%	if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(8));
	else strTemp = WI.fillTextValue("sub_user_index");  %>
				
                <%=dbOP.loadCombo("USER_INDEX","lname +'  .  '+  fname +' . ( '+ID_NUMBER+' ) '",
				" FROM USER_TABLE WHERE (AUTH_TYPE_INDEX <>4 and AUTH_TYPE_INDEX<>6) or AUTH_TYPE_INDEX is null order by lname",strTemp,false)%> </select> 
              <input name="lname_sub" type="text" size="16" maxlength="32" onKeyUp ="AutoScrollList('staff_profile.lname_sub','staff_profile.sub_user_index',true);" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'" > 
              <font size="1">(type lastname)</font> </td>
          </tr>
          <tr> 
            <td height="10" colspan="3"><hr size="1"></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="2"><u> Request Status:</u> </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="2"><select name="stat_req">
                <option value="2">Pending/On-process</option>
<% if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(13));
	else strTemp = "2";
		
	if (strTemp.compareTo("3") ==0){%>				
                <option value="3" selected>Pending/On-process - Recommends Approval by Vice-President concerned</option>
	<%}else{%>
                <option value="3">Pending/On-process - Recommends Approval by Vice-President concerned</option>
	<%}if (strTemp.compareTo("4") == 0){%>								
                <option value="4" selected>Pending/On-process - Recommends Approval by President</option>
	<%}else{%>
                <option value="4">Pending/On-process - Recommends Approval by President</option>
	<%} if (strTemp.compareTo("1") == 0){%>				
                <option value="1" selected>Approved</option>
	<%}else{%>
                <option value="1">Approved</option>
	<%} if (strTemp.compareTo("0") == 0){%>				
                <option value="0" selected>Disapproved</option>
	<%}else{%>
                <option value="0">Disapproved</option>
	<%}%>
              </select> </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="2">Date of Request Status Update :
<% if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(14));
	else strTemp = WI.fillTextValue("stat_update_date"); %>

              <input name="stat_update_date" type="text" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" 
			  onblur="style.backgroundColor='white';AllowOnlyIntegerExtn('staff_profile','stat_update_date','/')" 
			  onKeyUp="AllowOnlyIntegerExtn('staff_profile','stat_update_date','/')"  
			  value="<%=WI.getStrValue(strTemp)%>" size="10" maxlength="10"> 
              <a href="javascript:show_calendar('staff_profile.stat_update_date');" title="Click to select date" onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"><img src="../../../images/calendar_new.gif" width="20" height="16" border="0"></a> 
            </td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="2">Remarks : <br> 
<% if (vEditInfo != null) strTemp = WI.getStrValue((String)vEditInfo.elementAt(15));
	else strTemp = WI.fillTextValue("remark"); %>
              <textarea name="remark" cols="48" rows="3" class="textbox" onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"><%=strTemp%></textarea></td>
          </tr>
          <tr> 
            <td height="25">&nbsp;</td>
            <td height="25" colspan="2">&nbsp;</td>
          </tr>
        </table>
<% if (vEditInfo != null) {
	strTemp = (String)vEditInfo.elementAt(2);
	if (strTemp.compareTo("1") == 0 || strTemp.compareTo("3") ==0){
		strTemp = (String)vEditInfo.elementAt(4);
		if (strTemp.compareTo("1") == 0 || strTemp.compareTo("3") ==0){
			strTemp = (String)vEditInfo.elementAt(6);
		}
	}
	
	if (strTemp.equals("1") || strTemp.equals("3")){
%>
	
        <table width="53%" border="0" align="center" cellpadding="0" cellspacing="0" class="thinborder">
          <tr> 
            <td height="30" bgcolor="#6A77CC" class="thinborder"><div align="center"><strong><font color="#FFFFFF"> 
                EMPLOYEE WAS ABLE TO COMPLETE REQUIREMENTS</font></strong></div></td>
          </tr>
          <tr>
            <td height="25" class="thinborder"><strong>
<% if (WI.getStrValue((String)vEditInfo.elementAt(16)).length() != 0) strTemp = "checked"; 
   else strTemp ="";%>		
              <input name="is_completed" type="checkbox" value="1" <%=strTemp%>>
              check to add seminar/workshop to employee records</strong></td>
          </tr>
        </table>
<% 	}//		if (strTemp.compareTo("1") == 0 || strTemp.compareTo("3") ==0)
  }//(vEditInfo != null)
} 
%>
      </td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="2" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="2"> <div align="center"> 
          <%
		  	//System.out.println("iAccessLevel: "+iAccessLevel);
			//System.out.println("vEditInfo: "+vEditInfo);
		   if (iAccessLevel > 1){
			if (vEditInfo  == null){%>
          <a href="javascript:AddRecord();"><img src="../../../images/save.gif" border="0" name="hide_save"></a> 
          <font size="1">click to save entries</font> 
          <%}else{ %>
          <a href="javascript:EditRecord();"><img src="../../../images/edit.gif" border="0"></a> 
          <font size="1">click to save changes</font><a href='javascript:CancelRecord("<%=request.getParameter("emp_id")%>")'><img src="../../../images/cancel.gif" border="0"></a><font size="1">click 
          to cancel and clear entries</font> 
          <%} // end else vEdit Info == null
		  } // end iAccessLevel  > 1%>
          <br>
        </div></td>
    </tr>
    <tr>
      <td height="20" colspan="2">&nbsp;</td>
    </tr>
  </table>
<% if (vRetResult != null && vRetResult.size() > 0) {
	String[] astrType={"&nbsp;", "Official Time","Official Bus.","Rep. / Proxy" };
	String[] astrStat ={"Disapproved","Approved","Pending", "Pending - VP", "Pending - Pres"};
	
%>
  <table width="100%" border="0" cellpadding="1" cellspacing="0" bgcolor="#FFFFFF" class="thinborder">
    <tr bgcolor="#DBEEE0"> 
      <td height="25" colspan="8" class="thinborder"><div align="center"><strong>LIST 
          OF TRAINING APPLICATIONS </strong></div></td>
    </tr>
    <tr> 
      <td width="25%" height="25" class="thinborder"><strong>NAME OF TRAINING</strong></td>
      <td width="10%" class="thinborder"><strong>SCOPE</strong></td>
      <td width="25%" class="thinborder"><strong>VENUE (PLACE) <br>
        (CONDUCTED BY ) </strong></td>
      <td width="10%" class="thinborder"><strong>DATE</strong></td>
      <td width="10%" class="thinborder"><strong>STATUS</strong></td>
      <td width="7%" class="thinborder"><strong>DETAIL</strong> </td>
      <td width="6%" class="thinborder"><strong>EDIT</strong></td>
      <td width="7%" class="thinborder"><strong>DELETE</strong></td>
    </tr>
    <% for (int i=0 ; i < vRetResult.size(); i+=34){%>
    <tr> 
      <td height="25" class="thinborder"><%=(String)vRetResult.elementAt(i+21)%></td>
      <td class="thinborder"><%=WI.getStrValue((String)vRetResult.elementAt(i+19),"&nbsp;")%></td>
	<% strTemp = WI.getStrValue((String)vRetResult.elementAt(i+22));
	   if (strTemp.length() == 0) 
		   	strTemp = WI.getStrValue((String)vRetResult.elementAt(i+32));
		else
			strTemp += WI.getStrValue((String)vRetResult.elementAt(i+32), "&nbsp;(",")", "");  %>
			
      <td class="thinborder"><%=strTemp + WI.getStrValue((String)vRetResult.elementAt(i+28),"<br> (",")","&nbsp") %></td>
      <td class="thinborder"><%=(String)vRetResult.elementAt(i+29) + WI.getStrValue((String)vRetResult.elementAt(i+30)," - ", "","")%></td>
      <td class="thinborder"><%=astrStat[Integer.parseInt(WI.getStrValue((String)vRetResult.elementAt(i+13),"2"))]%></td>
      <td class="thinborder"><a href="javascript:ViewDetail(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../../images/view.gif" width="40" height="31" border="0"></a></td>
      <td class="thinborder">
	  
<% strTemp = WI.getStrValue((String)vRetResult.elementAt(i+13),"2");
if ((bolMyHome && strTemp.compareTo("2") == 0 && iAccessLevel > 1) || (!bolMyHome && iAccessLevel > 1)){%>
	  <a href="javascript:PrepareToEdit(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../../images/edit.gif" width="40" height="26" border="0"></a>
<%}else{%> N/A <%}%>	  
	  </td>
      <td class="thinborder"> <% 
		strTemp = (String) vRetResult.elementAt(i+13);
		if (strTemp.compareTo("1") != 0 && strTemp.compareTo("0") != 0) {
	 %> <a href="javascript:DeleteRecord(<%=(String)vRetResult.elementAt(i)%>)"><img src="../../../images/delete.gif" width="55" height="28" border="0"></a> 
        <%}else{%> &nbsp; <%}%> </td>
    </tr>
    <%}%>
  </table>
<% } //vRetResult != null && vRetResult.size() > 0%>
<%} //vEmpRec !=null && vEmpRec.size() > 0 && strTemp.trim().length() > 1%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A" class="footerDynamic">&nbsp;</td>
      </tr>
  </table>
<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
<input type="hidden" name="page_action">
<input type="hidden" name="prepareToEdit" value="<%=strPrepareToEdit%>">
<input type="hidden" name="my_home" value="<%=WI.fillTextValue("my_home")%>">
<input type="hidden" name="is_forwarded" value="<%=strIsForwarded%>">

<input type="hidden" name="opner_form_name" value="<%=WI.getStrValue(WI.fillTextValue("opner_form_name"),"staff_profile")%>"> 
<input type="hidden" name="close_wnd_called" value="0">
<input type="hidden" name="donot_call_close_wnd">
</form>
</body>
</html>
<%
	dbOP.cleanUP();
%>

