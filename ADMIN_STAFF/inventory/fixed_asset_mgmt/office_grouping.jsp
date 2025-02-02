<%@ page language="java" import="utility.*, inventory.InvFixedAssetMngt, java.util.Vector"%>
<%
WebInterface WI = new WebInterface(request);
	///added code for school/companies.
	boolean bolIsSchool = false;
	if((new CommonUtil().getIsSchool(null)).equals("1"))
		bolIsSchool = true;

%>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title>Inventory Entry Log</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<link href="../../../css/fontstyle.css" rel="stylesheet" type="text/css">
<link href="../../../css/tableBorder.css" rel="stylesheet" type="text/css">
<script language="javascript"  src ="../../../jscript/common.js" ></script>
<script language="javascript"  src ="../../../jscript/date-picker.js" ></script>
<script>
function ReloadPage()
{	
	this.SubmitOnce('form_');
}

function PageAction(strAction, strInfoIndex) {
	document.form_.page_action.value = strAction;
	if(strInfoIndex.length > 0)
		document.form_.info_index.value = strInfoIndex;		
	if(strAction == 1) 
		document.form_.hide_save.src = "../../../images/blank.gif";
	this.SubmitOnce('form_');
}
function viewList(table,indexname,colname,labelname,tablelist,strIndexes, strExtraTableCond,strExtraCond,strFormField){
	var loadPg = "../../HR/hr_updatelist.jsp?tablename=" + table + "&indexname=" + indexname + "&colname=" + colname+"&label="+escape(labelname)+
	"&table_list="+escape(tablelist)+
	"&indexes="+escape(strIndexes)+"&extra_tbl_cond="+escape(strExtraTableCond)+"&extra_cond="+escape(strExtraCond) +
	"&opner_form_name=form_&opner_form_field="+strFormField;
	
	var win=window.open(loadPg,"myfile",'dependent=yes,width=650,height=350,top=10,left=10,scrollbars=yes,toolbar=no,location=no,directories=no,status=no,menubar=no');
	win.focus();
}

function PrepareToEdit(strInfoIndex) {
	document.form_.info_index.value = strInfoIndex;
	document.form_.page_action.value = "";
	document.form_.prepareToEdit.value = "1";
	this.SubmitOnce('form_');
}
function CancelClicked(){
	document.form_.prepareToEdit.value = "";
	this.SubmitOnce('form_');
}
</script>
</head>
<%
	//authenticate user access level	
	int iAccessLevel = -1;
	java.util.Hashtable svhAuth = (java.util.Hashtable)request.getSession(false).getAttribute("svhAuth");
	
	if(svhAuth == null)
		iAccessLevel = -1; // user is logged out.
	else if (svhAuth.size() == 1 && svhAuth.get("ALL") != null)//super user.
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("ALL"),"0"));
	else {
		iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY-LOG"),"0"));
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("INVENTORY"),"0"));
		}
		if(iAccessLevel == 0) {
			iAccessLevel = Integer.parseInt(WI.getStrValue(svhAuth.get("EXECUTIVE MANAGEMENT SYSTEM"),"0"));
		}
	}
	
	if(iAccessLevel == -1)//for fatal error.
	{
		request.getSession(false).setAttribute("go_home","../ADMIN_STAFF/main%20files/admin_staff_home_button_content.htm");
		request.getSession(false).setAttribute("errorMessage","You are logged out. Please login again.");
		response.sendRedirect("../../commfile/fatal_error.jsp");
		return;
	}
	else if(iAccessLevel == 0)//NOT AUTHORIZED.
	{
		response.sendRedirect("../../../commfile/unauthorized_page.jsp");
		return;
	}
	
	DBOperation dbOP = new DBOperation((String)request.getSession(false).getAttribute("userId"),
							"INVENTORY-INVENTORY LOG","office_grouping.jsp");
		
	InvFixedAssetMngt InvFAM = new InvFixedAssetMngt();	
	Vector vRetResult = null;
	String strErrMsg = null;
	String strTemp = null;
	String strTemp2 = null;
	boolean bolEditMode = false;
	String strReadOnly = "";
	String strPageAction = WI.fillTextValue("page_action");
	String strPrepareToEdit = WI.fillTextValue("prepareToEdit");

	if(strPageAction.length() > 0){
		if(InvFAM.operateOnOfficeGroup(dbOP,request,Integer.parseInt(strPageAction)) == null)
			strErrMsg = InvFAM.getErrMsg();
		strPrepareToEdit = "";
	}

	vRetResult = InvFAM.operateOnOfficeGroup(dbOP,request,4);	
%>
<body bgcolor="#D2AE72">
<form name="form_" action="./office_grouping.jsp" method="post">
  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr bgcolor="#A49A6A"> 
      <td height="25" colspan="3" bgcolor="#A49A6A"><div align="center"><font color="#FFFFFF" size="2" face="Verdana, Arial, Helvetica, sans-serif"><strong>:::: 
          FIXED ASSETS MANAGEMENT - OFFICE GROUPING PAGE ::::</strong></font></div></td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><%=WI.getStrValue(strErrMsg,"&nbsp;")%></td>
    </tr>
    <tr> 
      <td height="25" width="6%">&nbsp;</td>
      <td width="16%">Asset Type</td>
      <td> <font size="1">
        <select name="group_index" onChange="ReloadPage();">
          <option value="">Select Type</option>
          <%
			strTemp = WI.fillTextValue("group_index");			
		  %>
          <%=dbOP.loadCombo("group_index","group_name"," from inv_user_group order by group_name", strTemp, false)%> 
        </select>
        <a href='javascript:viewList("inv_user_group","group_index","group_name","USER GROUP",
		"inv_item","group_index","","","group_index")'><img src="../../../images/update.gif" border="0"></a> 
        click to update USER GROUP list</font> <a href="javascript:show_calendar('form_.inv_date');" title="Click to select date" 
	onMouseOver="window.status='Select date';return true;" onMouseOut="window.status='';return true;"> 
        </a></td>
    </tr>
    <tr> 
      <td height="25" colspan="3"><hr size="1"></td>
    </tr>
  </table>

  <table width="100%" border="0" cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="18" width="6%">&nbsp;</td>
      <td width="16%"><%if(bolIsSchool){%>College<%}else{%>Division<%}%></td>
      <td> <font size="1"> 
        <%
      strTemp = WI.fillTextValue("c_index");%>
        <select name="c_index" onChange="ReloadPage();">
          <option value="0">Office</option>
          <%=dbOP.loadCombo("c_index","C_NAME"," from COLLEGE where IS_DEL=0 order by c_name asc", strTemp, false)%> 
        </select>
        </font></td>
    </tr>
    <tr> 
      <td height="18">&nbsp;</td>
      <td>Department</td>
      <td> <input type="text" name="starts_with" value="<%=WI.fillTextValue("starts_with")%>" size="12" class="textbox"
	   onFocus="style.backgroundColor='#D3EBFF'" onBlur="style.backgroundColor='white'"
	   onKeyUp = "AutoScrollList('form_.starts_with','form_.d_index',true);" >
        <%
		strTemp2 = WI.fillTextValue("d_index");
		%> <select name="d_index">
          <% if(strTemp!=null && strTemp.compareTo("0") !=0){%>
          <option value="">All</option>
          <%}  
   if (strTemp == null || strTemp.length() == 0 || strTemp.compareTo("0") == 0) strTemp = " and (c_index = 0 or c_index is null) ";
	  else strTemp = " and c_index = " +  strTemp;
%>
          <%=dbOP.loadCombo("d_index","d_NAME"," from department where IS_DEL=0 " + strTemp + " order by d_name asc",strTemp2, false)%> </select></td>
    </tr>
  </table>
  <table width="100%"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td>&nbsp;</td>
    </tr>
    <tr> 
      <td width="73%"><div align="center">
          <%if(strPrepareToEdit.compareTo("1") != 0) {%>
          <a href='javascript:PageAction(1, "");'> <img src="../../../images/save.gif" border="0" id="hide_save"></a><font size="1"> 
          click to save entries</font> 		
		  <%}%>
          <a href="./office_grouping.jsp"><img src="../../../images/cancel.gif" border="0"></a> 
          <font size="1"> click to 
          cancel or clear entries</font></div></td>
    </tr>
  </table>

  <%if (vRetResult != null && vRetResult.size() > 0){%>
  <table width="100%" border="0"  cellpadding="0" cellspacing="0" bgcolor="#FFFFFF">
    <tr> 
      <td height="25" colspan="3" bgcolor="#B9B292" class="thinborderBOTTOM"><div align="center"><strong>LIST 
          OF DEPARTMENTS / OFFICES UNDER THE SELECTED GROUP</strong></div></td>
    </tr>
    <tr> 
      <td width="41%" height="25" class="thinborderBOTTOMLEFT"><div align="center"><font size="1"><strong>COLLEGE</strong></font></div></td>
      <td width="47%" class="thinborderBOTTOMLEFT"><div align="center"><font size="1"><strong>DEPARTMENT 
          / OFFICE</strong></font></div></td>

      <td width="12%" class="thinborderBOTTOMLEFTRIGHT">&nbsp;</td>
    </tr>
    <%for(int i = 0;i < vRetResult.size(); i+=5){%>
    <tr> 
      <td height="25" class="thinborderBOTTOMLEFT">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+1),"Non-academic Office")%>&nbsp;</td>
      <td class="thinborderBOTTOMLEFT">&nbsp;<%=WI.getStrValue((String)vRetResult.elementAt(i+3))%>&nbsp;</td>
      <td class="thinborderBOTTOMLEFTRIGHT"><div align="center"> <a href='javascript:PageAction(0,"<%=WI.getStrValue((String)vRetResult.elementAt(i))%>");'><img src="../../../images/delete.gif" width="55" height="28" border="0"></a></div></td>
    </tr>
    <%}%>
  </table>
  <%}// end if vRetResult != null%>
  <table  bgcolor="#FFFFFF" width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr> 
      <td height="25"  colspan="3">&nbsp;</td>
    </tr>
    <tr>
      <td height="25"  colspan="3" bgcolor="#A49A6A">&nbsp;</td>
    </tr>
  </table>
    <input type="hidden" name="page_action">
	<input type="hidden" name="info_index" value="<%=WI.fillTextValue("info_index")%>">
</form>
</body>
</html>
<%
dbOP.cleanUP();
%>